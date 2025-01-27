# still need to split off authentication scripts 
from wikibaseintegrator import WikibaseIntegrator
from wikibaseintegrator.wbi_config import config as wbi_config
import time

# set Wikibase parameters of the TRE for wbi
wbi_config['USER_AGENT'] = 'WikibaseIntegrator/1.0 (https://www.wikidata.org/wiki/User:Matdillen)'
wbi_config['MEDIAWIKI_API_URL'] = 'https://tre-test.wikibase.cloud/w/api.php'
wbi_config['SPARQL_ENDPOINT_URL'] = 'https://tre-test.wikibase.cloud/query/sparql'
wbi_config['WIKIBASE_URL'] = 'https://tre-test.wikibase.cloud/wiki/'

# import oauth1 keys from oauth_config.py
## oauth_config file needs to contain (tokens generated from https://tre-test.wikibase.cloud/wiki/Special:OAuthConsumerRegistration):
### oauth_consumer_token = "thetoken"
### oauth_consumer_secret = "thetoken"
### oauth_access_token = "thetoken"
### oauth_access_secret = "thetoken"
import oauth_config
from wikibaseintegrator import wbi_login
#import the authentication tokens
login_instance = wbi_login.OAuth1(consumer_token=oauth_config.oauth_consumer_token, consumer_secret=oauth_config.oauth_consumer_secret,
    access_token=oauth_config.oauth_access_token, access_secret=oauth_config.oauth_access_secret)

wbi = WikibaseIntegrator(login=login_instance)

# load the classes of Wikibase data types to be used
from wikibaseintegrator.datatypes import ExternalID, Item, String, Time

# read the data file to populate the wikibase with typification items
import pandas as pd
typifications = pd.read_csv("typifications-wbi.tsv",sep="\t",dtype=str)

# set which lines to import, to work in batches from a local machine
# start line:
init = 60000
# endline:
endit = len(typifications)
#endit = 60000

# function to transform |-delimited strings into 
## multiple claims to add to the item
def process_and_append(column_value, prop_nr, data_list):
    if '|' in column_value:
        for part in column_value.split('|'):
            data_list.append(String(value=part.strip(), prop_nr=prop_nr))
    else:
        data_list.append(String(value=column_value.strip(), prop_nr=prop_nr))
        
# some data elements may exceed wikibase label rules, so they get truncated  
def truncate_string(input_string):
    if len(input_string) > 250:
        index = input_string.find("at the locality of")
        if index != -1:
            return input_string[:index]
    return input_string

# try to write errors to a logfile
quicklog = open("quicklog.txt","a+")

# import the typifications
for i in range(init,endit):
    # create a new item
    item = wbi.item.new()
    
    # add item label (english)
    item.labels.set(language='en', value=typifications['typeStatusLabel'][i])

    # Set a English description
    item.descriptions.set(language = 'en', value = "link between a specimen and the name it is a type for")
    
    # instance of claim:
    statements = Item(value='Q47338', prop_nr='P1')
    data = [statements]
    
    # add the taxon name item for the typification
    data.append(Item(value=typifications['item.x'][i],prop_nr='P29'))
    
    # add the typestatus item for the typification
    data.append(Item(value=typifications['item.y'][i],prop_nr='P30'))
    
    # add the specimen item for the typification
    data.append(Item(value=typifications['typeSpecimen'][i],prop_nr='P36'))
    
    # add the items for the data sources (of name and specimen)
    data.append(Item(value='Q52455',prop_nr='P8'))
    data.append(Item(value='Q62776',prop_nr='P8'))
    
    item.claims.add(data)
    
    # try to catch the timeout error, which may result in a rejected duplicate item and therefore a crash
    try:
        item.write()
    except ModificationFailed as error:
        print(error.info)
        quicklog.write(error.info + "\n")
        quicklog.write(typifications['typeStatusLabel'][i] + "\n")
    # limit to max 10 per s to spare the API
    time.sleep(0.1)
quicklog.close()

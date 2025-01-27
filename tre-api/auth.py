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

# read the data file to populate the wikibase with name items
import pandas as pd
names = pd.read_csv("names-wbi.tsv",sep="\t")

# set which lines to import, to work in batches from a local machine
# start line:
init = 10001
# endline:
#endit = len(names)
endit = 20000

# function to transform |-delimited strings into 
## multiple claims to add to the item
def process_and_append(column_value, prop_nr, data_list):
    if '|' in column_value:
        for part in column_value.split('|'):
            data_list.append(String(value=part.strip(), prop_nr=prop_nr))
    else:
        data_list.append(String(value=column_value.strip(), prop_nr=prop_nr))

# import the taxon names
for i in range(init,endit):
    # create a new item
    item = wbi.item.new()
    
    # add item label (english)
    item.labels.set(language='en', value=names['fullname'][i])

    # Set an English description
    item.descriptions.set(language='en', value="a botanical taxonomic name of rank species")
    
    # instance of claim:
    statements = Item(value='Q1', prop_nr='P1')
    data = [statements]
    
    # add taxon rank
    data.append(Item(value=names['rank'][i],prop_nr='P5'))
    
    # add kingdom (as string)
    data.append(String(value='Plantae',prop_nr='P16'))
    
    # add name as string
    data.append(String(value=names['fullname'][i],prop_nr='P14'))
    
    # add authorship as string
    data.append(String(value=names['authorship'][i],prop_nr='P15'))
    
    # add ipni name ids (can be more than one)
    process_and_append(names['ipni'][i],'P32',data)
    
    # add gbif taxon ids (can be more than one)
    process_and_append(names['taxonKey'][i],'P7',data)
    
    # set claims to the new item 
    item.claims.add(data)
    
    # push the item to the mediawiki API
    item.write()
    
    # limit to max 10 per s to spare the API
    time.sleep(0.1)

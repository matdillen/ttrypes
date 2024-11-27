from wikibaseintegrator import WikibaseIntegrator
from wikibaseintegrator.wbi_config import config as wbi_config
import time

wbi_config['USER_AGENT'] = 'WikibaseIntegrator/1.0 (https://www.wikidata.org/wiki/User:Matdillen)'
wbi_config['MEDIAWIKI_API_URL'] = 'https://tre-test.wikibase.cloud/w/api.php'
wbi_config['SPARQL_ENDPOINT_URL'] = 'https://tre-test.wikibase.cloud/query/sparql'
wbi_config['WIKIBASE_URL'] = 'https://tre-test.wikibase.cloud/wiki/'

import oauth_config
from wikibaseintegrator import wbi_login
#import the authentication tokens
login_instance = wbi_login.OAuth1(consumer_token=oauth_config.oauth_consumer_token, consumer_secret=oauth_config.oauth_consumer_secret,
    access_token=oauth_config.oauth_access_token, access_secret=oauth_config.oauth_access_secret)

wbi = WikibaseIntegrator(login=login_instance)

from wikibaseintegrator.datatypes import ExternalID, Item, String, Time
import pandas as pd

typifications = pd.read_csv("../imported/typificationsimported.tsv",sep="\t",dtype=str)

init = 21
endit = len(typifications)
#endit = 21

def process_and_append(column_value, prop_nr, data_list):
    if '|' in column_value:
        for part in column_value.split('|'):
            data_list.append(String(value=part.strip(), prop_nr=prop_nr))
    else:
        data_list.append(String(value=column_value.strip(), prop_nr=prop_nr))
        
def truncate_string(input_string):
    if len(input_string) > 250:
        index = input_string.find("at the locality of")
        if index != -1:
            return input_string[:index]
    return input_string

for i in range(init,endit):
    item = wbi.item.get(entity_id = typifications['typification'][i])
    claims = item.claims.get('P1')
    for claim in claims:
        claim.remove()
    
    item.claims.add(Item(value='Q47338',prop_nr='P1'))
    item.write()
    time.sleep(0.1)
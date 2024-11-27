#still need to split off authentication scripts 
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

names = pd.read_csv("names-wbi.tsv",sep="\t")

#change these to script arguments
init = 10001
#endit = len(names)
endit = 20000

def process_and_append(column_value, prop_nr, data_list):
    if '|' in column_value:
        for part in column_value.split('|'):
            data_list.append(String(value=part.strip(), prop_nr=prop_nr))
    else:
        data_list.append(String(value=column_value.strip(), prop_nr=prop_nr))

for i in range(init,endit):
    item = wbi.item.new()
    item.labels.set(language='en', value=names['fullname'][i])

    # Set a English description
    item.descriptions.set(language='en', value="a botanical taxonomic name of rank species")
    statements = Item(value='Q1', prop_nr='P1')
    data = [statements]
    data.append(Item(value=names['rank'][i],prop_nr='P5'))
    data.append(String(value='Plantae',prop_nr='P16'))
    data.append(String(value=names['fullname'][i],prop_nr='P14'))
    data.append(String(value=names['authorship'][i],prop_nr='P15'))
    process_and_append(names['ipni'][i],'P32',data)
    process_and_append(names['taxonKey'][i],'P7',data)
    item.claims.add(data)
    item.write()
    time.sleep(0.1)
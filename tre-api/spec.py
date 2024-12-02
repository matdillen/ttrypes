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
from wikibaseintegrator.datatypes.extra import EDTF
import pandas as pd

specimens = pd.read_csv("specimens-wbi.tsv",sep="\t",dtype=str)

init = 40000
endit = len(specimens)
#endit = 40000

def process_and_append(column_value, prop_nr, data_list):
    if '|' in column_value:
        for part in column_value.split('|'):
            data_list.append(String(value=part.strip(), prop_nr=prop_nr))
    else:
        data_list.append(String(value=column_value.strip(), prop_nr=prop_nr))
        
def truncate_string(s, max_length=50, truncation_indicator='[...]'):
    """Truncate a string to a maximum length, adding a truncation indicator if necessary."""
    if len(s) > max_length:
        return s[:max_length - len(truncation_indicator)] + truncation_indicator
    else:
        return s

for i in range(init,endit):
    item = wbi.item.new()
    item.labels.set(language='en', value=specimens['occurrenceID'][i])

    # Set a English description
    desc = "a plant specimen known as " + truncate_string(specimens['scientificName'][i])
    if specimens['recordedBy'][i] == specimens['recordedBy'][i]:
        desc += " collected by " + truncate_string(specimens['recordedBy'][i])
    if specimens['eventDate'][i] == specimens['eventDate'][i]:
        desc += " in " + truncate_string(specimens['eventDate'][i])
    if specimens['locality'][i] == specimens['locality'][i]:
        desc += " at the locality of " + truncate_string(specimens['locality'][i])
    item.descriptions.set(language = 'en', value = desc)
    
    statements = Item(value='Q4', prop_nr='P1')
    data = [statements]
    if specimens['recordedBy'][i] == specimens['recordedBy'][i]:
        data.append(String(value=truncate_string(specimens['recordedBy'][i],max_length = 400),prop_nr='P40'))
    if specimens['locality'][i] == specimens['locality'][i]:
        data.append(String(value=truncate_string(specimens['locality'][i],max_length = 400),prop_nr='P38'))
    if specimens['eventDate'][i] == specimens['eventDate'][i]:
        data.append(EDTF(value=specimens['eventDate'][i],prop_nr='P39'))
    if specimens['countryCode'][i] == specimens['countryCode'][i]:
        data.append(String(value=truncate_string(specimens['countryCode'][i],max_length = 400),prop_nr='P41'))
    data.append(Item(value=specimens['item'][i],prop_nr='P29'))
    process_and_append(specimens['gbifID'][i],'P34',data)
    data.append(String(value=specimens['scientificName'][i],prop_nr='P14'))
    if specimens['uri'][i] == specimens['uri'][i]:
        data.append(ExternalID(value=specimens['uri'][i],prop_nr='P35'))
    if specimens['col:institutionCode'][i] == specimens['col:institutionCode'][i]:
        data.append(String(value=specimens['col:institutionCode'][i],prop_nr='P26'))
    data.append(Item(value='Q52455',prop_nr='P8'))
    item.claims.add(data)
    item.write()
    time.sleep(0.1)
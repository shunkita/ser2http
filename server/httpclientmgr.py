import requests
import json
from functools import reduce
#
# Data Manager for Http Client
#
class HttpClientManager():
#       
# Command  ...
#   
    class Cmd():
        PARSE = 1
        QUERY = 2
        POST = 3
        PUT = 4
        DELETE = 5
        SEND_URL = 6
        CLOSE = 7
        EXIT = 99 

    def __init__(self):
        self.url = None
        self.jsondata = None
        self.cmd = HttpClientManager.Cmd

    def com_handle(self, com):
        if (com[0] == self.cmd.EXIT):
            exit()
        if (com[0] == self.cmd.PARSE):                  #Parse
            self.parse(com[1:])
        elif (com[0] == self.cmd.QUERY):                #Query
            response = self.query(com[1:])
            return(response)
        elif (com[0] == self.cmd.SEND_URL):             #Send URL
            self.send_url(com[1:])
        elif (com[0] == self.cmd.CLOSE):             	#Close
            self.close()
        elif (com[0] == self.cmd.POST):                #Post
            self.post(com[1:])
        elif (com[0] == self.cmd.PUT):                 #Put
            self.put(com[1:])
        elif (com[0] == self.cmd.DELETE):              #Delete
            self.delete(com[1:])
        else:
            print(f"data exception error {com[0]}")
#            dump_bytearray(request_data)
 
    def parse(self, request_data):
        try:
            response = requests.get(request_data)
            response.raise_for_status()  # Check for HTTP request errors
            self.jsondata = response.json()
        except requests.exceptions.RequestException as e:
            print(f"Parse exception: HTTP error occurred: {e}")
            self.jsondata = None
        except ValueError as e:
            print(f"Parse exception: Invalid JSON response: {e}")
            self.jsondata = None

    def query(self, query):
        try:
#            print(self.jsondata)
# '/'で分割してリストに変換
            keys = query.decode('ascii').split('/')

# reduceを使ってネストされた辞書から値を取得
            def safe_get(d, key):
                if isinstance(d, dict) and key in d:
                    return d[key]
                elif isinstance(d, list) and key.isdigit() and int(key) < len(d):
                    return d[int(key)]
                else:
                    print(f"Key '{key}' not found in {d}")
                    return 'empty'
    
            query_result = reduce(safe_get, keys, self.jsondata)
            
            if query_result is not None:
                return str(query_result)
            else:
                print("Query result is None.")
                return 'empty'
    
        except AttributeError as e:
            print(f"HttpClientManager.query: exception {e}")
            return None
        except Exception as e:
            print(f"HttpClientManager.query: exception {e}")
            return None

    def send_url(self, data):
        self.url = data

    def post(self, data):
        if (self.url == None):
            print("HttpClientManager.post: url is empty ")
            exit()
        try:
        # dataがbytes型の場合、デコードしてPythonオブジェクトに変換
            if isinstance(data, bytes):
				# bytesを文字列に変換してからJSONにパース
                json_data = json.loads(data.decode('utf-8')) 
                post_result = requests.post(self.url, json=json_data)
                print(post_result)
                self.jsondata = post_result.json()
 
        except Exception as e:
            print(f"HttpClientManager.post: exception {e}")
            print(data)
            return None
#
    def close(self):
            self.url = None
            self.jsondata = None
#
    def put(self, data):
        if (self.url == None):
            print("HttpClientManager.post: url is empty ")
            exit()
        try:
            if isinstance(data, bytes):
#                json_data = json.loads(data.decode('utf-8')) 
                json_data = json.loads(data.decode('ISO-8859-1'))

                put_result = requests.put(self.url, json=json_data)
                print(put_result)
                self.jsondata = put_result.json()
 
        except Exception as e:
            print(f"HttpClientManager.put: exception {e}")
            return None

    def delete(self, data=None):
        if self.url is None:
            print("HttpClientManager.delete: url is empty")
            exit()
        
        try:
            if data and isinstance(data, bytes):
                data = json.loads(data.decode('utf-8'))
    
            # DELETEリクエストの場合、データをbodyに含める必要がなければ、単純なDELETEリクエスト
            if data:
                delete_result = requests.delete(self.url, json=data)
            else:
                delete_result = requests.delete(self.url)
    
            print(delete_result)
    
        except json.JSONDecodeError as e:
            print(f"HttpClientManager.delete: invalid JSON data: {e}")
            return None
        except Exception as e:
            print(f"HttpClientManager.delete: exception {e}")
            return None

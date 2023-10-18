# python request lib
import requests

#url parameters
p = {"firstname": "Rayhan", "lastName": "Alam", "age": "26"}

# HTTP get used for retrieving data from specified source. params is for GET-style URL parameters
r = requests.get("https://httpbin.org/get", params=p)

print(r.status_code)

# Returns response as byte
print(r.content)

# Returns response body that is decoded by the requests lib being used
print(r.text)
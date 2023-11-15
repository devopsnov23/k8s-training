**YAML** Ain't a Markup Language (YAML), and as configuration formats go, it's easy on the eyes. It has an intuitive visual structure, and its logic is pretty simple: indented bullet points inherit properties of parent bullet points.   
   
But this apparent simplicity can be deceptive.   
   
It's easy (and misleading) to think of YAML as just a list of related values, no more complex than a shopping list. There is a heading and some items beneath it. The items below the heading relate directly to it, right? Well, you can test this theory by writing a little bit of valid YAML.   
   
Open a text editor and enter this text, retaining the dashes at the top of the file and the leading spaces for the last two items:   
   
---   
Store: Bakery   
  Sourdough loaf   
  Bagels   
   
Save the file as example.yaml    
   
If you don't already have yamllint installed, install it:   
   
sudo apt-get install yamllint   
   
A linter is an application that verifies the syntax of a file. The yamllint command is a great way to ensure your YAML is valid before you hand it over to whatever application you're writing YAML for (Ansible, for instance).   
   
Use yamllint to validate your YAML file:   
```console   
$ yamllint --strict shop.yaml || echo “Fail”   
$   
``` 
### How data is stored in YAML   
YAML can contain different kinds of data blocks:   
   
Sequence: values listed in a specific order. A sequence starts with a dash and a space (-). You can think of a sequence as a Python list or an array in Bash or Perl.   
Mapping: key and value pairs. Each key must be unique, and the order doesn't matter. Think of a Python dictionary or a variable assignment in a Bash script.   
There's a third type called scalar, which is arbitrary data (encoded in Unicode) such as strings, integers, dates, and so on. In practice, these are the words and numbers you type when building mapping and sequence blocks, so you won't think about these any more than you ponder the words of your native tongue.   
   
When constructing YAML, it might help to think of YAML as either a sequence of sequences or a map of maps, but not both.   
   
### Key Value Pair   
Fruit: Apple    
Vegatable: Carrot    
Liquid: Water    
Meat: Chicken    
   
### Array / List   
Fruits   
-  Orange    
-  Apple    
-  Grapes    
   
Vegatables    
- Carrot    
- Beans    
- Tomato   
   
### Dictionary / Map    
Banana:   
  Calories: 105    
  Fat: 0.4    
  Carbs: 27    
   
Grapes:   
  Calories: 85   
  Fat: 0.3   
  Carbs: 16   
   
### List of Dictionaries    
Fruits:   
-  Banana:   
     Calories: 105    
     Fat: 0.4    
     Carbs: 27    
   
-  Grapes:   
     Calories: 85   
     Fat: 0.3   
     Carbs: 16   
   
   
### Dictionary vs List    
Dictionary - To store different properties of a single object    
List - To store multiple of a same type    
   
Dictionay is unordered. Elements of dictionary can be defined in any order.    
List is ordered collection. Two lists will not be the same if the elements of the lists are not in the same order.      
   

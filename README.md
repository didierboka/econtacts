# E-Contacts App

A Swift UIKit project making to load, add (coming soon), delete (coming soon) and call (coming soon) synchronized contacts from internet.


## Features
- Load contacts
- Cached contacts loaded
- Search contact
- Lazy loading with infinite scroll

## Features Coming
- Save contact
- Calling contact
- Update exist contact
- Delete contact

## Dictionary

- `NetworkMonitorService` : the class handle network connectivity when device connected or not
- `ContactManagerCoreData` : is a manager CoreData for persistence contacts loaded on internet for cached 
- `ContactViewController` : our view controller that show the list of contacts loaded on network or cache and search contact view
- `ContactItemView` : the occurence of view of contact element on list
- `ContactDetailViewController` : our view controller that show the details of clicked on one contact
- `ContactViewModels` : a viewmodel that manage the logic of loading contact on network, search contact, manage cached contact
- `ContactModel` : model of api response, contact data and other model

## License

MIT

**Free Software, Hell Yeah! Download and test it !!!**

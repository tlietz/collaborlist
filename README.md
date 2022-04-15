# Collaborlist

Make lists for personal use, or collaborate on them with others, all from within a browser window.
Check items off on the list, or strikethrough them.
The list is updated in real time.

I personally use this for groceries.
Once I put an item into my cart, I check it off the list. 
If the store does not have something, I strikethrough it.
Whenever somebody at home thinks of an item to add, they just add it to the list.

The app is made with the Phoenix Elixir server. Websockets are used to implement the real time functionality. 
Postgres is used to persist data.

---

## Application Design

A list that a user is working displays its name and potentially other metadata such as how many collaborators there are on a certain list. 
Managing the CRUD operations on entire lists is different from managing the CRUD operations on items of a list.
A `Catalog` context is a good place for the management of lists. 
This leaves a `List` context to mange the list items of each list. 


## Database

The Postgres database has 3 main resources; `User`, `List`, and `ListItem`. 

The relationship between a `User` and a `List` is `many-to-many` because a `List` can have multiple users working on it, and a `User` can work on multiple lists.
A `List` is not deleted from the database unless all `User`s working on it have deleted it.

The relationship between a `List` and a `ListItem` is `one-to-many` because a `List` can have multiple list items, but each `ListItem` is associated to only one `List`.
This also means that, a `ListItem` belongs to a `List`.

## Features

- [ ] Create lists
- [ ] Delete lists
- [ ] Add items to lists
- [ ] Delete items from lists
- [ ] Strikethrough lists
- [ ] Undo deleting items
- [ ] Drag and drop to reorder list items
- [ ] Invite to collaborate on list via link
- [ ] Invite to collaborate on list via QR code

## Future Todos

- [ ] Login with gmail account
- [ ] Reset lists
- [ ] Make copies of lists
- [ ] Encrypt of lists stored in database
- [ ] Undo deleting lists
- [ ] List owners with permissions (for example, delete list for all)
- [ ] Export lists as text file
- [ ] Search for lists and list items
- [ ] Email options such as notifying upon list changing

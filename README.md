# Collaborlist

Make lists for personal use, or collaborate on them with others, all from within a browser window.
Check items off on the list, or strikethrough them.
The list is updated in real time.

The app is made with Elixir and the Phoenix framework. Websockets are used to implement the real time functionality. 
Postgres is used as a database.

---

## Application Design

A list that a user is working needs to display its name and potentially other metadata such as how many collaborators there are on a certain list. 
Managing the CRUD operations on entire list is different from managing the CRUD operations on items of a list.
A `Catalog` context is a good place for the management of lists. 
A `List` context will manage the items of each individual list. 


## Database

The Postgres database has 3 main resources: `User`, `List`, and `ListItem`. 

The relationship between a `User` and a `List` is `many-to-many` because a `List` can have multiple users working on it, and a `User` can work on multiple lists.
A `List` is not deleted from the database unless all `User`s working on it have deleted it.

The relationship between a `List` and a `ListItem` is `one-to-many` because a `List` can have multiple list items, but each `ListItem` is associated to only one `List`.

## User Auth

There is an option to sign in with Google to the application.
It is JWT-based and is used for authentication only. 
Once a user is authenticated with Google sign in, 
they are given a `session_id` cookie, 
and any authorization is done via a session-based workflow. 

Part of the motivation for using *JWT authentication* and *session-based authorization* was the information given in this article: ["Stop using JWT for session"](http://cryto.net/~joepie91/blog/2016/06/13/stop-using-jwt-for-sessions/).

## Collaborating with other users on a list

Once a user creates a list, they can add users in two ways:
1) By email
2) An invite link

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
- [ ] Create an account through the app.
- [ ] Google sign in

## Future Todos

- [ ] Try to speed up database retrievals by splitting up the `list_items` table into multiple tables, each corresponding to a list
- [ ] Link app account to Google sign in.
- [ ] Reset lists
- [ ] Make copies of lists
- [ ] Undo actions
- [ ] Encrypt all data stored in database
- [ ] List owners with permissions (for example, delete list for all)
- [ ] Export lists as text file
- [ ] Search for lists and list items
- [ ] Email options such as notifying upon list changing

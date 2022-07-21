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

## Collaboration Invite Links

Users can create a collaboration invite link with an expiry time and 
a maximum number of uses. 

In the database, the `invites` table has `invite_code` as its primary 
key, and a column that stores the `list_id` the invite link is for.
When a user creates an invite link, a `UUID` is generated and stored as the `invite_code`.

The link created looks something like:
`https://collaborlist.com/invite/qwerty12345`


When a client navigates to the `/invite/:invite_code` endpoint, 
if the `invite_code` exists and if it's not expired, the client is 
routed to a register page, login page, or the list based on their 
account status.

Two appraoches were considered to purge stale invite links:

1) Using a genserver to spawn processes that know which invite link to delete at what time
2) Doing a check at set time intervals 

Approach `1` is more "elixir-ish" and elegant with it's use of a process.
However, if something happens to the server, and the genserver fails at the wrong time, a stale invite link might be able to slip by.
If that were to happen, approach `2` would have to be implemented as a failsafe anyways.
Therefore, to keep things simpler, only approach `2` is used. 

## Features

- [x] Create lists
- [x] Delete lists
- [x] Add items to lists
- [x] Delete items from lists
- [x] Create an account through the app.
- [x] Google sign in
- [ ] Display collaborators on a list
- [ ] Strikethrough or checkmark list items
- [ ] Invite to collaborate on list via link
- [ ] Collaborate on lists in real-time

## Future Todos

- [ ] Link app account to Google sign in.
- [ ] Drag and drop to reorder list items
- [ ] Invite to collaborate on list via QR code
- [ ] Reset lists
- [ ] Make copies of lists
- [ ] Undo actions
- [ ] Encrypt all data stored in database
- [ ] List owners with permissions (for example, delete list for all)
- [ ] Export lists as text file
- [ ] Search for lists and list items
- [ ] Email options such as notifying upon list changing

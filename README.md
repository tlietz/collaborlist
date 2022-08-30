# Collaborlist

Make lists for personal use, or collaborate on them with others, all from within a browser window.
Check items off on the list, or strikethrough them.
The list is updated in real time.

The app is made with Elixir and the Phoenix framework. Websockets are used to implement the real time functionality. 
Postgres is used as a database.

---

## Why Elixir?

TODO: Concurrent application, and Phoenix framework has LiveView to make real-time concurrent applications.

## User Auth

There is an option to sign in with Google to the application.
It is JWT-based and is used for authentication only. 
Once a user is authenticated with Google sign in, 
they are given a `session_id` cookie, 
and any authorization is done via a session-based workflow. 

Part of the motivation for using *JWT authentication* and *session-based authorization* was the information given in this article: ["Stop using JWT for session"](http://cryto.net/~joepie91/blog/2016/06/13/stop-using-jwt-for-sessions/).

## Guest User

If a user is not signed into an account, they will be automatically signed in as a guest. 
This way, they are able to use the app immideately.

When a user that was previously a guest registers for an account, the guest user's `is_guest` field is changed from `true` to `false`. 
This allows all progress to be saved as long as the user used the guest account on only one device.

## Invite Links

Users can create a collaboration invite link.

In the database, the `invites` table has `invite_code` as its primary 
key, and a column that stores the `list_id` the invite link is for.
When a user creates an invite link, a `UUID string` is generated and stored as the `invite_code`.

The link created looks something like:
`https://collaborlist.com/invites/qwerty12345`

When a client navigates to the `/invites/:invite_code` endpoint, 
if the `invite_code` exists, the currently logged in user
will be added as a collaborator to the list that the invite was created for. 
The client is then redirected to the index page of that list. If no user was logged in, a guest user will be logged in and added as the collaborator. 

The invite links are created dynamically in `invites_view.ex` using the `invite_code`. 
The links aren't statically stored in a database because if the url of the website were to change in the future, a database migration would need to occur. 

An invite is stored permanently until any one of the following occurs:
- A user manually deletes the invite
- The list that an invite is associated with is deleted
- The user that created the invite is deleted

## Features

- [x] Create lists
- [x] Delete lists
- [x] Add items to lists
- [x] Delete items from lists
- [x] Create an account through the app.
- [x] Google sign in
- [x] Strikethrough or checkmark list items
- [x] Invite to collaborate on list via link
- [x] User can delete invites
- [x] Collaborate on lists in real-time

## Future Improvements

- [ ] Show number of users currently on a list
- [ ] Show if a user is currently editing a list item
- [ ] User can delete themselves
- [ ] Click to copy invite links
- [ ] Sort lists and list items in various ways
- [ ] Add privilege levels (viewer and collaborator)
- [ ] Purge guest accounts that exceed the max age
- [ ] Time limiting requests to prevent spammers
- [ ] Link app account to Google sign in.
- [ ] Display collaborators on a list 
- [ ] Drag and drop to reorder list items
- [ ] Invite to collaborate on list via QR code
- [ ] Reset lists
- [ ] Make copies of lists
- [ ] Undo actions
- [ ] Encrypt all data stored in database
- [ ] Export lists as text file
- [ ] Search for lists and list items
- [ ] Email options such as notifying upon list changing
- [ ] Invites with expiry time and limited number of uses
- [ ] Rest API to automate list creation and editing
- [ ] When using an invite link, if user is not logged in, route to a page that allows them to select between: continue as guest, register new account, or login to existing account 

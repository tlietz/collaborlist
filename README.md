# Collaborlist

Make lists for personal use, or collaborate on them with others.
You can check items off on the list, or strikethrough them.
The list is updated in real time if someone adds an item.

I personally use this for groceries.
Once I put an item into my cart, I check it off the list. 
If the store does not have something, I strikethrough it.
Whenever somebody at home thinks of an item to add, they just add it to the list.

The app is made with the Phoenix Elixir server. Websockets are used to implement the real time functionality. 
Postgres is used to persist data.

---

## Database

The Postgres database has 3 main resources; `User`, `List`, and `ListItem`. 

The relationship between a `User` and a `List` is `many-to-many` because a `List` can have multiple users working on it, and a `User` can work on multiple lists.

The relationship between a `List` and a `ListItem` is `one-to-many` because a `List` can have multiple list items, but each `ListItem` is associated to only one `List`.

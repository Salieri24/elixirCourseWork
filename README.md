# Elixir Course work

A small elixir project for uni.

Task :


Course work (graded)
---
```
Instructions
  1. Create a User struct with the following parameters: [username, password, email, sex, is_logged_in] `is_logged_in` is telling us whether the User is logged in ot not.
  2. Write a GenServer called Database that holds Users which exposes the following functionality:
    a) Add new User (here we mean a struct User) to the GenServer (Database). If there is already a User with the same email/username, return an error.
    c) Be able to login as a User. The function should take a username and password as parameters. When a User logs in his state should show that he is logged in.
    d) You cannot log in with more than one user at a time. You should not be able to login as UserB if UserA is already logged in.
    c) Be able to delete a User by providing a username.
    d) Be able to change a password for a User by providing a username, current password and new password. Change password can only be called from a logged in User. You shouldn't be able to change a password to a User that is not logged in.
    e) Be able to logout.
    f) Be able to show all users in the database.
 
  3. The GenServer should expose the following client functions:
    - create/1 (takes a User struct)
    - login/2 (takes a username and password)
    - logout/1 (takes a username)
    - change_password/3 (takes a username, current_password, new_password)
    - delete/1 (takes a username)
    - show/0 (returns all Users in the database)
 ```

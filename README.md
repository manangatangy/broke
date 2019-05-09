# Broke

Record and browse all the times you give $ to your kids.

### Project Structure

Folders for 
- models: data structures for database and other records
- widgets: UI components
- services: app-wide, bloc, scoped-models etc

### Data flow
The Bloc manages various streams which distribute data around the
app.

The Repo class collects together data from firestore and uses it 
to form objects better suited to the ui layer.  These objects are
passed to the bloc, which distributes them to the
appropriate parts of the widget tree.





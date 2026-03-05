const express = require('express');
const { v4: uuidv4 } = require('uuid');

const app = express();
app.use(express.json());

// In-memory storage for todos
let todos = [];

// Validation middleware
const validateTodo = (req, res, next) => {
  const { title, completed } = req.body;
  const errors = [];

  if (req.method === 'POST' || req.body.title !== undefined) {
    if (typeof title !== 'string' || title.trim().length === 0) {
      errors.push('Title is required and must be a non-empty string');
    }
    if (title && title.length > 200) {
      errors.push('Title must be 200 characters or less');
    }
  }

  if (completed !== undefined && typeof completed !== 'boolean') {
    errors.push('Completed must be a boolean');
  }

  if (errors.length > 0) {
    return res.status(400).json({ errors });
  }

  next();
};

// GET /todos - List all todos
app.get('/todos', (req, res) => {
  res.json(todos);
});

// GET /todos/:id - Get a single todo
app.get('/todos/:id', (req, res) => {
  const todo = todos.find(t => t.id === req.params.id);
  if (!todo) {
    return res.status(404).json({ error: 'Todo not found' });
  }
  res.json(todo);
});

// POST /todos - Create a new todo
app.post('/todos', validateTodo, (req, res) => {
  const todo = {
    id: uuidv4(),
    title: req.body.title.trim(),
    completed: req.body.completed || false,
    createdAt: new Date().toISOString()
  };
  todos.push(todo);
  res.status(201).json(todo);
});

// PUT /todos/:id - Update a todo
app.put('/todos/:id', validateTodo, (req, res) => {
  const index = todos.findIndex(t => t.id === req.params.id);
  if (index === -1) {
    return res.status(404).json({ error: 'Todo not found' });
  }

  const updatedTodo = {
    ...todos[index],
    title: req.body.title !== undefined ? req.body.title.trim() : todos[index].title,
    completed: req.body.completed !== undefined ? req.body.completed : todos[index].completed,
    updatedAt: new Date().toISOString()
  };

  todos[index] = updatedTodo;
  res.json(updatedTodo);
});

// DELETE /todos/:id - Delete a todo
app.delete('/todos/:id', (req, res) => {
  const index = todos.findIndex(t => t.id === req.params.id);
  if (index === -1) {
    return res.status(404).json({ error: 'Todo not found' });
  }

  todos.splice(index, 1);
  res.status(204).send();
});

// Reset todos (for testing)
app.resetTodos = () => {
  todos = [];
};

module.exports = app;

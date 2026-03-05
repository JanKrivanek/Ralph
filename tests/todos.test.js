const request = require('supertest');
const app = require('../src/app');

describe('Todo API', () => {
  beforeEach(() => {
    app.resetTodos();
  });

  describe('GET /todos', () => {
    it('should return empty array initially', async () => {
      const res = await request(app).get('/todos');
      expect(res.status).toBe(200);
      expect(res.body).toEqual([]);
    });

    it('should return all todos', async () => {
      await request(app)
        .post('/todos')
        .send({ title: 'Test todo' });

      const res = await request(app).get('/todos');
      expect(res.status).toBe(200);
      expect(res.body).toHaveLength(1);
    });
  });

  describe('GET /todos/:id', () => {
    it('should return a todo by id', async () => {
      const createRes = await request(app)
        .post('/todos')
        .send({ title: 'Test todo' });

      const res = await request(app).get(`/todos/${createRes.body.id}`);
      expect(res.status).toBe(200);
      expect(res.body.title).toBe('Test todo');
    });

    it('should return 404 for non-existent todo', async () => {
      const res = await request(app).get('/todos/non-existent-id');
      expect(res.status).toBe(404);
      expect(res.body.error).toBe('Todo not found');
    });
  });

  describe('POST /todos', () => {
    it('should create a new todo', async () => {
      const res = await request(app)
        .post('/todos')
        .send({ title: 'New todo' });

      expect(res.status).toBe(201);
      expect(res.body.title).toBe('New todo');
      expect(res.body.completed).toBe(false);
      expect(res.body.id).toBeDefined();
      expect(res.body.createdAt).toBeDefined();
    });

    it('should create a todo with completed status', async () => {
      const res = await request(app)
        .post('/todos')
        .send({ title: 'Done todo', completed: true });

      expect(res.status).toBe(201);
      expect(res.body.completed).toBe(true);
    });

    it('should trim whitespace from title', async () => {
      const res = await request(app)
        .post('/todos')
        .send({ title: '  Trimmed title  ' });

      expect(res.body.title).toBe('Trimmed title');
    });

    it('should return 400 for missing title', async () => {
      const res = await request(app)
        .post('/todos')
        .send({});

      expect(res.status).toBe(400);
      expect(res.body.errors).toContain('Title is required and must be a non-empty string');
    });

    it('should return 400 for empty title', async () => {
      const res = await request(app)
        .post('/todos')
        .send({ title: '   ' });

      expect(res.status).toBe(400);
    });

    it('should return 400 for title too long', async () => {
      const res = await request(app)
        .post('/todos')
        .send({ title: 'a'.repeat(201) });

      expect(res.status).toBe(400);
      expect(res.body.errors).toContain('Title must be 200 characters or less');
    });

    it('should return 400 for invalid completed type', async () => {
      const res = await request(app)
        .post('/todos')
        .send({ title: 'Test', completed: 'true' });

      expect(res.status).toBe(400);
      expect(res.body.errors).toContain('Completed must be a boolean');
    });
  });

  describe('PUT /todos/:id', () => {
    it('should update a todo title', async () => {
      const createRes = await request(app)
        .post('/todos')
        .send({ title: 'Original' });

      const res = await request(app)
        .put(`/todos/${createRes.body.id}`)
        .send({ title: 'Updated' });

      expect(res.status).toBe(200);
      expect(res.body.title).toBe('Updated');
      expect(res.body.updatedAt).toBeDefined();
    });

    it('should update todo completed status', async () => {
      const createRes = await request(app)
        .post('/todos')
        .send({ title: 'Test' });

      const res = await request(app)
        .put(`/todos/${createRes.body.id}`)
        .send({ completed: true });

      expect(res.status).toBe(200);
      expect(res.body.completed).toBe(true);
    });

    it('should return 404 for non-existent todo', async () => {
      const res = await request(app)
        .put('/todos/non-existent-id')
        .send({ title: 'Updated' });

      expect(res.status).toBe(404);
    });

    it('should validate input on update', async () => {
      const createRes = await request(app)
        .post('/todos')
        .send({ title: 'Test' });

      const res = await request(app)
        .put(`/todos/${createRes.body.id}`)
        .send({ title: '' });

      expect(res.status).toBe(400);
    });
  });

  describe('DELETE /todos/:id', () => {
    it('should delete a todo', async () => {
      const createRes = await request(app)
        .post('/todos')
        .send({ title: 'To delete' });

      const deleteRes = await request(app).delete(`/todos/${createRes.body.id}`);
      expect(deleteRes.status).toBe(204);

      const getRes = await request(app).get(`/todos/${createRes.body.id}`);
      expect(getRes.status).toBe(404);
    });

    it('should return 404 for non-existent todo', async () => {
      const res = await request(app).delete('/todos/non-existent-id');
      expect(res.status).toBe(404);
    });
  });
});

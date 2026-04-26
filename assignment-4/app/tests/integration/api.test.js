const request = require('supertest');
const { app } = require('../../server');

describe('Integration Tests - API Endpoints', () => {
  test('GET /health returns 200 and ok status', async () => {
    const res = await request(app).get('/health');
    expect(res.statusCode).toBe(200);
    expect(res.body.status).toBe('ok');
  });
  test('GET /api/hello returns greeting', async () => {
    const res = await request(app).get('/api/hello');
    expect(res.statusCode).toBe(200);
    expect(res.body.message).toContain('Hello');
  });
  test('POST /api/add returns sum', async () => {
    const res = await request(app).post('/api/add').send({ a: 3, b: 7 });
    expect(res.statusCode).toBe(200);
    expect(res.body.result).toBe(10);
  });
});
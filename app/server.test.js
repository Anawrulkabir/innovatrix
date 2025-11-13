const request = require('supertest');
const { app, server } = require('./server');

// Set test environment
process.env.NODE_ENV = 'test';

afterAll((done) => {
  if (server) {
    server.close(done);
  } else {
    done();
  }
});

describe('Demo App Tests', () => {
  describe('GET /', () => {
    it('should return hello world message', async () => {
      const response = await request(app).get('/');
      expect(response.status).toBe(200);
      expect(response.body.message).toContain('Hello World');
      expect(response.body.timestamp).toBeDefined();
    });
  });

  describe('GET /health', () => {
    it('should return healthy status', async () => {
      const response = await request(app).get('/health');
      expect(response.status).toBe(200);
      expect(response.body.status).toBe('healthy');
      expect(response.body.service).toBe('demo-app');
      expect(response.body.uptime).toBeDefined();
      expect(response.body.timestamp).toBeDefined();
    });
  });

  describe('GET /unknown', () => {
    it('should return 404 for unknown routes', async () => {
      const response = await request(app).get('/unknown');
      expect(response.status).toBe(404);
    });
  });
});
import { describe, it, expect, vi, beforeEach, afterEach } from 'vitest';
import { UnipeptSubcommand } from '../../../lib/commands/unipept/unipept_subcommand.js';

// Concrete implementation for testing abstract class
class TestSubcommand extends UnipeptSubcommand {
    constructor() {
        super('test');
    }
    defaultBatchSize(): number { return 10; }
}

describe('UnipeptSubcommand Retry Logic', () => {
    let command: TestSubcommand;
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    let fetchSpy: any;

    beforeEach(() => {
        command = new TestSubcommand();
        // @ts-ignore
        fetchSpy = vi.spyOn(global, 'fetch');
    });

    afterEach(() => {
        vi.restoreAllMocks();
    });

    it('should retry on 500 error', async () => {
        // Mock fetch to fail with 500 once, then succeed
        fetchSpy
            .mockResolvedValueOnce({
                ok: false,
                status: 500,
                statusText: 'Internal Server Error'
            } as Response)
            .mockResolvedValueOnce({
                ok: true,
                status: 200,
                statusText: 'OK'
            } as Response);

        const result = await command.fetchWithRetry('http://example.com', {}, 3);
        expect(result.ok).toBe(true);
        expect(fetchSpy).toHaveBeenCalledTimes(2);
    });

    it('should retry on network error', async () => {
        fetchSpy
            .mockRejectedValueOnce(new Error('Network error'))
            .mockResolvedValueOnce({
                ok: true,
                status: 200,
                statusText: 'OK'
            } as Response);

        const result = await command.fetchWithRetry('http://example.com', {}, 3);
        expect(result.ok).toBe(true);
        expect(fetchSpy).toHaveBeenCalledTimes(2);
    });

    it('should NOT retry on 404 error', async () => {
        fetchSpy.mockResolvedValue({
            ok: false,
            status: 404,
            statusText: 'Not Found'
        } as Response);

        await expect(command.fetchWithRetry('http://example.com', {}, 3))
            .rejects.toMatch(/Failed to fetch data from the Unipept API: 404 Not Found/);

        expect(fetchSpy).toHaveBeenCalledTimes(1);
    });

    it('should NOT retry on 400 error', async () => {
        fetchSpy.mockResolvedValue({
            ok: false,
            status: 400,
            statusText: 'Bad Request'
        } as Response);

        await expect(command.fetchWithRetry('http://example.com', {}, 3))
            .rejects.toMatch(/Failed to fetch data from the Unipept API: 400 Bad Request/);

        expect(fetchSpy).toHaveBeenCalledTimes(1);
    });

    it('should retry on 429 error', async () => {
        fetchSpy
            .mockResolvedValueOnce({
                ok: false,
                status: 429,
                statusText: 'Too Many Requests'
            } as Response)
            .mockResolvedValueOnce({
                ok: true,
                status: 200,
                statusText: 'OK'
            } as Response);

        const result = await command.fetchWithRetry('http://example.com', {}, 3);
        expect(result.ok).toBe(true);
        expect(fetchSpy).toHaveBeenCalledTimes(2);
    });
});

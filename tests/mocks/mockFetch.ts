import { vi } from 'vitest';
import * as apiData from './apiData';

export function setupMockFetch() {
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    (global as any).fetch = vi.fn((url: string | URL, options?: RequestInit) => {
        const urlString = url.toString();

        // eslint-disable-next-line @typescript-eslint/no-explicit-any
        let bodyInput: any = [];
        let bodyEquate: boolean = false;
        let bodyExtra: boolean = false;

        if (options && options.body) {
            try {
                const parsedBody = JSON.parse(options.body as string);
                bodyInput = parsedBody.input;
                bodyEquate = parsedBody.equate_il;
                bodyExtra = parsedBody.extra;
            } catch (e) {
                // ignore
            }
        }

        // Helper to check for AALTER input
        const isAALTER = Array.isArray(bodyInput) && bodyInput.length === 1 && bodyInput[0] === "AALTER";
        const isP78330 = Array.isArray(bodyInput) && bodyInput.length === 1 && bodyInput[0] === "P78330";
        const isTaxon = Array.isArray(bodyInput) && bodyInput.length === 1 && bodyInput[0] === 216816;
        const isTaxa2Lca = Array.isArray(bodyInput) && bodyInput.length === 2 && bodyInput.includes(216816) && bodyInput.includes(1680);

        // Verify options for basic tests (expecting false/undefined for equate and extra)
        const optionsOk = !bodyEquate && !bodyExtra;

        if (urlString.endsWith("pept2prot.json")) {
            if (isAALTER && optionsOk) {
                return Promise.resolve({
                    ok: true,
                    json: () => Promise.resolve(apiData.pept2protResponse)
                });
            }
        }
        if (urlString.endsWith("pept2taxa.json")) {
            if (isAALTER && optionsOk) {
                return Promise.resolve({
                    ok: true,
                    json: () => Promise.resolve(apiData.pept2taxaResponse)
                });
            }
        }
        if (urlString.endsWith("pept2lca.json")) {
            if (isAALTER && optionsOk) {
                return Promise.resolve({
                    ok: true,
                    json: () => Promise.resolve(apiData.pept2lcaResponse)
                });
            }
        }
        if (urlString.endsWith("peptinfo.json")) {
            if (isAALTER && optionsOk) {
                return Promise.resolve({
                    ok: true,
                    json: () => Promise.resolve(apiData.peptinfoResponse)
                });
            }
        }
        if (urlString.endsWith("pept2ec.json")) {
            if (isAALTER && optionsOk) {
                return Promise.resolve({
                    ok: true,
                    json: () => Promise.resolve(apiData.pept2ecResponse)
                });
            }
        }
        if (urlString.endsWith("pept2go.json")) {
            if (isAALTER && optionsOk) {
                return Promise.resolve({
                    ok: true,
                    json: () => Promise.resolve(apiData.pept2goResponse)
                });
            }
        }
        if (urlString.endsWith("pept2interpro.json")) {
             if (isAALTER && optionsOk) {
                return Promise.resolve({
                    ok: true,
                    json: () => Promise.resolve(apiData.pept2interproResponse)
                });
             }
        }
         if (urlString.endsWith("pept2funct.json")) {
             if (isAALTER && optionsOk) {
                return Promise.resolve({
                    ok: true,
                    json: () => Promise.resolve(apiData.pept2functResponse)
                });
             }
        }
        if (urlString.endsWith("taxa2lca.json")) {
             if (isTaxa2Lca) {
                 return Promise.resolve({
                    ok: true,
                    json: () => Promise.resolve(apiData.taxa2lcaResponse)
                });
             }
        }
        if (urlString.endsWith("taxonomy.json")) {
             if (isTaxon) {
                return Promise.resolve({
                    ok: true,
                    json: () => Promise.resolve(apiData.taxonomyResponse)
                });
             }
        }
        if (urlString.endsWith("protinfo.json")) {
             if (isP78330) {
                return Promise.resolve({
                    ok: true,
                    json: () => Promise.resolve(apiData.protinfoResponse)
                });
             }
        }

        // If no match found, reject or return 404
        return Promise.resolve({
            ok: false,
            status: 404,
            statusText: "Not Found or Invalid Mock Input",
            json: () => Promise.resolve([])
        });
    });
}

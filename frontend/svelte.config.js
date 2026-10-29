import adapterNode from '@sveltejs/adapter-node';
import { vitePreprocess } from '@sveltejs/vite-plugin-svelte';

const isNetlify = Boolean(process.env.NETLIFY || process.env.ADAPTER === 'netlify');

let selectedAdapter;
if (isNetlify) {
	try {
		const { default: adapterNetlify } = await import('@sveltejs/adapter-netlify');
		selectedAdapter = adapterNetlify();
	} catch {
		selectedAdapter = adapterNode();
	}
} else {
	selectedAdapter = adapterNode();
}

/** @type {import('@sveltejs/kit').Config} */
const config = {
	// Consult https://kit.svelte.dev/docs/integrations#preprocessors
	// for more information about preprocessors
	preprocess: vitePreprocess(),

	kit: {
		// adapter-auto only supports some environments, see https://kit.svelte.dev/docs/adapter-auto for a list.
		// If your environment is not supported or you settled on a specific environment, switch out the adapter.
		// See https://kit.svelte.dev/docs/adapters for more information about adapters.
		adapter: selectedAdapter,

		alias: {
			$paraglide: './src/paraglide/'
		}
	}
};

export default config;

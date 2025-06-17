<script lang="ts">
	import { base } from '$app/paths';
	import { dashboard } from '$lib/Stores';

	export let initial: any;

	let css;

	/**
	 * Map the theme entries into CSS variables
	 */
	$: {
		// Map existing theme properties to CSS variables (backward compatibility)
		css = Object.entries(initial?.theme || {})
			.map(([key, value]) => {
				if (typeof value === 'string' && value.includes('/themes/')) {
					value = value.replace('/', `${base}/`);
				}
				return `--theme-${key}: ${value};`;
			})
			.join(' ');

		// Map theme properties to design system tokens for enhanced styling
		const themeTokens = mapThemeToDesignTokens(initial?.theme || {});
		if (themeTokens) {
			css += ' ' + themeTokens;
		}

		if ($dashboard?.theme && !import.meta.env.SSR) {
			if (initial?.title !== $dashboard.theme) {
				loadTheme($dashboard.theme);
			}
		}
	}

	/**
	 * Map theme properties to modern design system tokens
	 * This bridges existing themes with our new design system
	 */
	function mapThemeToDesignTokens(theme: Record<string, any>): string {
		const mappings: Array<[string, string]> = [];

		// Map colors
		if (theme['colors-text']) {
			mappings.push(['--color-text-primary', theme['colors-text']]);
		}
		if (theme['colors-icon']) {
			mappings.push(['--color-text-secondary', theme['colors-icon']]);
		}
		if (theme['colors-title']) {
			mappings.push(['--color-text-heading', theme['colors-title']]);
		}

		// Map background colors with fallbacks
		if (theme['colors-sidebar-background']) {
			mappings.push(['--color-surface-elevated', theme['colors-sidebar-background']]);
		}
		if (theme['modal-background-color']) {
			mappings.push(['--color-overlay-medium', theme['modal-background-color']]);
		}
		if (theme['modal-background-color-modal']) {
			mappings.push(['--color-surface-modal', theme['modal-background-color-modal']]);
		}

		// Map button colors
		if (theme['button-background-color-on']) {
			mappings.push(['--color-accent-surface', theme['button-background-color-on']]);
		}
		if (theme['button-background-color-off']) {
			mappings.push(['--color-surface-secondary', theme['button-background-color-off']]);
		}

		// Map borders and spacing
		if (theme['border-radius']) {
			mappings.push(['--radius-base', theme['border-radius']]);
		}
		if (theme['colors-sidebar-border']) {
			const borderValue = theme['colors-sidebar-border'].replace('1px solid ', '');
			mappings.push(['--color-border-subtle', borderValue]);
		}

		// Map font properties
		if (theme['font-family']) {
			mappings.push(['--font-family-override', theme['font-family']]);
		}

		// Map app color for accent
		if (theme['app-color']) {
			mappings.push(['--color-accent-primary', theme['app-color']]);
		}

		return mappings.map(([property, value]) => `${property}: ${value};`).join(' ');
	}

	/**
	 * Load theme by name from backend
	 */
	async function loadTheme(name: string) {
		try {
			const response = await fetch(`${base}/_api/load_theme`, {
				method: 'POST',
				headers: {
					'Content-Type': 'application/json'
				},
				body: JSON.stringify({ theme: name })
			});

			const data = await response.json();

			if (response.ok) {
				initial = data;
			} else {
				throw new Error(data.message);
			}
		} catch (error) {
			console.error(error);
		}
	}
</script>

<svelte:head>
	{@html `<style>:root {${css}}</style>`}
	<meta name="theme-color" content={initial?.theme?.['app-color']} />
</svelte:head>

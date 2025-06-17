<script lang="ts">
	import { motion } from '$lib/Stores';
	import { fade } from 'svelte/transition';
	import { Modals, closeModal } from 'svelte-modals';
	import Loader from '$lib/Components/Loader.svelte';
	import '@fontsource-variable/inter';
	import { expoOut } from 'svelte/easing';
	
	// Import modern design system
	import '$lib/styles/tokens.css';
	import '$lib/styles/components.css';
	import '$lib/styles/utilities.css';
</script>

<svelte:head>
	<title>FUSION</title>
	<meta name="description" content="fusion" />
	<meta charset="utf-8" />
</svelte:head>

<Modals>
	<div
		slot="backdrop"
		class="backdrop"
		on:click={() => {
			closeModal();
		}}
		in:fade={{
			duration: $motion,
			easing: expoOut
		}}
		out:fade={{ duration: $motion / 2 }}
		on:keydown
		role="button"
		tabindex="0"
	></div>

	<div slot="loading">
		<Loader />
	</div>
</Modals>

<slot />

<style>
	:global(body, html) {
		margin: 0;
		padding: 0;
		-webkit-tap-highlight-color: transparent;
		box-sizing: border-box;
	}

	:global(html) {
		/* Enhanced with design system tokens */
		background-color: var(--theme-colors-background, var(--color-background));
		color: var(--theme-colors-text, var(--color-text-primary));
		font-size: var(--font-size-base);
		/* Smooth transitions for theme changes */
		transition: background-color var(--transition-medium), color var(--transition-medium);
	}

	:global(body) {
		/* Enhanced background with design system */
		background: var(--theme-colors-background, var(--color-background));
		font-family: var(--theme-font-family, var(--font-family-sans));
		font-size: var(--font-size-base);
		line-height: var(--line-height-normal);
		font-weight: var(--font-weight-normal);
		user-select: none;
		-webkit-user-select: none;
		background-size: cover;
		background-repeat: no-repeat;
		background-attachment: fixed;
		transition: 
			background-image var(--transition-fast),
			background-color var(--transition-medium),
			color var(--transition-medium);
		
		/* Modern scrollbar styling */
		scrollbar-width: thin;
		scrollbar-color: var(--color-border-strong) transparent;
	}

	/* Modern scrollbar for webkit browsers */
	:global(body::-webkit-scrollbar) {
		width: 8px;
		height: 8px;
	}

	:global(body::-webkit-scrollbar-track) {
		background: transparent;
	}

	:global(body::-webkit-scrollbar-thumb) {
		background-color: var(--color-border-strong);
		border-radius: var(--radius-full);
		border: 2px solid transparent;
		background-clip: content-box;
	}

	:global(body::-webkit-scrollbar-thumb:hover) {
		background-color: var(--color-border-interactive);
	}

	:global(*, *::before, *::after, *:focus) {
		box-sizing: inherit;
	}

	.backdrop {
		position: fixed;
		top: 0;
		bottom: 0;
		right: 0;
		left: 0;
		z-index: var(--z-modal-backdrop);
		background: var(--color-overlay-strong);
		backdrop-filter: blur(var(--blur-md));
		-webkit-backdrop-filter: blur(var(--blur-md));
		background-size: cover;
		background-repeat: no-repeat;
		background-attachment: fixed;
		transition: 
			opacity var(--transition-medium) var(--easing-out),
			backdrop-filter var(--transition-medium) var(--easing-out);
	}
</style>

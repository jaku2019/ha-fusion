<script lang="ts">
	import { dashboard, lang, record } from '$lib/Stores';
	import { onDestroy } from 'svelte';
	import Iframe from '$lib/Main/Iframe.svelte';
	import InputClear from '$lib/Components/InputClear.svelte';
	import ConfigButtons from '$lib/Modal/ConfigButtons.svelte';
	import Modal from '$lib/Modal/Index.svelte';
	import { updateObj } from '$lib/Utils';
	import type { IframeItem } from '$lib/Types';

	export let isOpen: boolean;
	export let sel: IframeItem;

	let url = sel?.url;
	let size = sel?.size;
	let urlError = '';
	let sizeError = '';

	function validateUrl(value: string | undefined) {
		if (!value) {
			urlError = '';
			return true;
		}
		try {
			new URL(value);
			if (!value.startsWith('http://') && !value.startsWith('https://')) {
				urlError = 'URL must start with http:// or https://';
				return false;
			}
			urlError = '';
			return true;
		} catch {
			urlError = 'Invalid URL format';
			return false;
		}
	}

	function validateSize(value: string | undefined) {
		if (!value) {
			sizeError = '';
			return true;
		}
		// Check if it's a valid CSS size value
		const sizeRegex = /^\d+(\.\d+)?(px|%|rem|em|vh|vw)$/;
		if (!sizeRegex.test(value)) {
			sizeError = 'Invalid size format (e.g., 300px, 50%, 20rem)';
			return false;
		}
		sizeError = '';
		return true;
	}

	function set(key: string, event?: any) {
		sel = updateObj(sel, key, event);
		$dashboard = $dashboard;
	}

	function handleUrlChange(event: Event) {
		const target = event.target as HTMLInputElement;
		url = target.value;
		if (validateUrl(url)) {
			set('url', event);
		}
	}

	function handleSizeChange(event: Event) {
		const target = event.target as HTMLInputElement;
		size = target.value;
		if (validateSize(size)) {
			set('size', event);
		}
	}

	onDestroy(() => $record());
</script>

{#if isOpen}
	<Modal>
		<h1 slot="title">{$lang('iframe')}</h1>

		<h2>{$lang('preview')}</h2>

		<div class="preview">
			<Iframe {sel} />
		</div>

		<h2>{$lang('url')}</h2>

		<InputClear
			condition={url}
			on:clear={() => {
				url = undefined;
				urlError = '';
				set('url');
			}}
			let:padding
		>
			<input
				type="text"
				class="input"
				bind:value={url}
				placeholder="https://"
				on:change={handleUrlChange}
				on:blur={() => validateUrl(url)}
				autocomplete="off"
				spellcheck="false"
				style:padding
			/>
		</InputClear>
		{#if urlError}
			<div class="error">{urlError}</div>
		{/if}

		<h2>{$lang('size')}</h2>

		<InputClear
			condition={size}
			on:clear={() => {
				size = undefined;
				sizeError = '';
				set('size');
			}}
			let:padding
		>
			<input
				type="text"
				class="input"
				bind:value={size}
				placeholder="300px"
				on:change={handleSizeChange}
				on:blur={() => validateSize(size)}
				autocomplete="off"
				spellcheck="false"
				style:padding
			/>
		</InputClear>
		{#if sizeError}
			<div class="error">{sizeError}</div>
		{/if}

		<ConfigButtons {sel} />
	</Modal>
{/if}

<style>
	.preview {
		border: 1px solid rgba(255, 255, 255, 0.2);
		border-radius: 0.8rem;
		padding: 1rem;
		background-color: rgba(0, 0, 0, 0.2);
	}

	.error {
		color: #ff6b6b;
		font-size: 0.875rem;
		margin-top: 0.5rem;
		margin-bottom: 0.5rem;
	}
</style>

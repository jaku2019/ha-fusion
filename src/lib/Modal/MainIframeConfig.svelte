<script lang="ts">
	import { dashboard, lang, record, ripple } from '$lib/Stores';
	import { onDestroy } from 'svelte';
	import Iframe from '$lib/Main/Iframe.svelte';
	import InputClear from '$lib/Components/InputClear.svelte';
	import ConfigButtons from '$lib/Modal/ConfigButtons.svelte';
	import Modal from '$lib/Modal/Index.svelte';
	import { updateObj } from '$lib/Utils';
	import type { IframeItem } from '$lib/Types';
	import Ripple from 'svelte-ripple';

	export let isOpen: boolean;
	export let sel: IframeItem;

	let url = sel?.url;
	let size = sel?.size;

	function set(key: string, event?: any) {
		sel = updateObj(sel, key, event);
		$dashboard = $dashboard;
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
				set('url');
			}}
			let:padding
		>
			<input
				type="text"
				class="input"
				bind:value={url}
				placeholder="https://"
				on:change={(event) => set('url', event)}
				autocomplete="off"
				spellcheck="false"
				style:padding
			/>
		</InputClear>

		<h2>{$lang('size')}</h2>

		<InputClear
			condition={size}
			on:clear={() => {
				size = undefined;
				set('size');
			}}
			let:padding
		>
			<input
				type="text"
				class="input"
				bind:value={size}
				placeholder="300px"
				on:change={(event) => set('size', event)}
				autocomplete="off"
				spellcheck="false"
				style:padding
			/>
		</InputClear>

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
</style>

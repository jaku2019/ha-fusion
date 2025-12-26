<script lang="ts">
	import { editMode, lang } from '$lib/Stores';
	import { openModal } from 'svelte-modals';
	import Icon from '@iconify/svelte';
	import type { IframeItem } from '$lib/Types';

	export let sel: IframeItem;

	$: url = sel?.url;
	$: size = sel?.size;

	function handleClick() {
		if ($editMode) {
			openModal(() => import('$lib/Modal/MainIframeConfig.svelte'), { sel });
		}
	}
</script>

<button
	class="container"
	class:preview={!url}
	on:click={handleClick}
	style:cursor={$editMode ? 'pointer' : 'default'}
>
	{#if url}
		<iframe
			src={url}
			style:height={size || '300px'}
			style:pointer-events={$editMode ? 'none' : 'auto'}
			title={$lang('iframe')}
		></iframe>
	{:else}
		<div class="placeholder" style:height={size || '300px'}>
			<div class="icon">
				<Icon icon="fontisto:world-o" height="none" />
			</div>
		</div>
	{/if}
</button>

<style>
	.container {
		display: block;
		border: none;
		padding: 0;
		margin: 0;
		background: transparent;
		width: 100%;
		overflow: hidden;
	}

	.container.preview {
		cursor: pointer;
	}

	iframe,
	.placeholder {
		display: block;
		border: 1px solid rgba(255, 255, 255, 0.2);
		border-radius: 0.65rem;
		width: 100%;
		background-color: rgba(0, 0, 0, 0.2);
	}

	.placeholder {
		display: flex;
		justify-content: center;
		align-items: center;
	}

	.icon {
		opacity: 0.2;
		width: 3.8rem;
		height: 3.8rem;
	}
</style>

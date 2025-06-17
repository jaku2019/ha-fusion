<script lang="ts">
	import { dashboard, motion, record, lang, ripple } from '$lib/Stores';
	import Ripple from 'svelte-ripple';
	import Icon from '@iconify/svelte';
	import { generateId } from '$lib/Utils';
	import { createEventDispatcher } from 'svelte';

	export let view: any;

	const dispatch = createEventDispatcher();

	$: noViewsOrSectionsOrStacks =
		!view ||
		!view.sections ||
		view.sections.length === 0 ||
		!hasValidSection(view.sections);

	function hasValidSection(sections: any[]): boolean {
		for (const section of sections) {
			// If it's not a horizontal-stack, it's a valid section for items
			if (section.type !== 'horizontal-stack') {
				return true;
			}
			// If it's a horizontal-stack, check nested sections
			if (section.sections && hasValidSection(section.sections)) {
				return true;
			}
		}
		return false;
	}

	/**
	 * Creates a new button object in
	 * first section of current view
	 */
	function handleClick() {
		if (noViewsOrSectionsOrStacks) return;

		const section = findSection(view.sections);

		if (!section) return;

		// Ensure the section has an items array
		if (!section.items) {
			section.items = [];
		}

		section.items.unshift({
			type: 'configure',
			id: generateId($dashboard)
		});

		$dashboard = $dashboard;
		$record();

		dispatch('clicked');
	}

	/**
	 * Finds the first section that is
	 * not of type 'horizontal-stack'.
	 */
	function findSection(sections: any[]): any | undefined {
		for (const section of sections) {
			if (section.type !== 'horizontal-stack') return section;
			const found = section.sections && findSection(section.sections);
			if (found) return found;
		}
	}
</script>

<button
	class="button dropdown"
	on:click={handleClick}
	use:Ripple={{
		...$ripple,
		opacity: noViewsOrSectionsOrStacks ? '0' : $ripple.opacity
	}}
	style:cursor={noViewsOrSectionsOrStacks ? 'unset' : 'pointer'}
	style:opacity={noViewsOrSectionsOrStacks ? '0.5' : '1'}
	style:transition="opacity {$motion}ms ease"
>
	<figure>
		<Icon icon="solar:file-bold-duotone" height="none" />
	</figure>

	{$lang('object')}
</button>

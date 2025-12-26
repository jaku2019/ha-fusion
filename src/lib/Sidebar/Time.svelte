<script lang="ts">
	import { timer, selectedLanguage } from '$lib/Stores';

	export let hour12: boolean | undefined = undefined;
	export let seconds: boolean | undefined = undefined;

	$: time = $timer.toLocaleTimeString($selectedLanguage, {
		hour: hour12 ? 'numeric' : '2-digit',
		minute: '2-digit',
		second: seconds ? '2-digit' : undefined,
		hour12: hour12
	});
</script>

<div>
	{time}
</div>

<style>
	div {
		padding: var(--theme-sidebar-item-padding, var(--space-4));
		font-weight: var(--font-medium);
		line-height: 2.8rem;
		font-size: var(--theme-sizes-sidebar-time, var(--text-2xl));

		/* Enhanced text styling with better shadows */
		text-shadow:
			0 2px 4px rgba(0, 0, 0, 0.3),
			0 1px 2px rgba(0, 0, 0, 0.2);
		color: var(--color-text-primary);

		/* Better text handling */
		white-space: nowrap;
		overflow: hidden;
		text-overflow: ellipsis;
		margin-left: -0.1rem;

		/* Modern styling */
		background: var(--color-glass-light);
		border-radius: var(--radius-lg);
		border: 1px solid var(--color-border-subtle);
		backdrop-filter: blur(var(--blur-sm));
		-webkit-backdrop-filter: blur(var(--blur-sm));

		/* Smooth transitions */
		transition: var(--transition-all);
		position: relative;

		/* Subtle gradient overlay */
		background-image: var(--gradient-glass);
	}

	/* Enhanced hover effect */
	div:hover {
		background: var(--color-glass-medium);
		border-color: var(--color-border-emphasis);
		transform: translateY(-1px);
		box-shadow: var(--shadow-md);
	}

	/* Modern focus state */
	div:focus-visible {
		outline: none;
		box-shadow: 0 0 0 3px var(--color-primary-hover);
	}

	/* Mobile optimizations */
	@media (max-width: 768px) {
		div {
			font-size: var(--text-xl);
			padding: var(--space-3);
		}

		div:hover {
			transform: none; /* Disable transform on mobile */
		}
	}

	/* Reduced motion accessibility */
	@media (prefers-reduced-motion: reduce) {
		div {
			transition: none;
		}

		div:hover {
			transform: none;
		}
	}

	/* Dark theme optimizations */
	@media (prefers-color-scheme: dark) {
		div {
			text-shadow:
				0 2px 8px rgba(0, 0, 0, 0.8),
				0 1px 4px rgba(0, 0, 0, 0.6);
		}
	}
</style>

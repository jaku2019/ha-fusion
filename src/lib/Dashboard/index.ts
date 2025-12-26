import Graph from './Graph.svelte';

export const components = {
	Graph
};

export const componentMeta = {
	Graph: {
		name: 'Graph',
		icon: 'mdi:chart-line',
		description: 'Display entity history as a line graph',
		configurable: true,
		requiresEntity: true,
		defaultConfig: {
			hours: 24,
			stroke_color: '#4fc3f7',
			fill_color: '#4fc3f740'
		}
	}
};

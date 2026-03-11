--!strict

export type BlockData = {
	--density: number
	Material: "dirt" | "air",
	Position: Vector3
}

export type BlocksMap = {{{BlockData}}}

export type ChunkData = {
	Blocks: BlocksMap
}

return {}
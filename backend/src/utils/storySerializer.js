function tenseIdToString(tenseId) {
  if (!tenseId) return '';
  if (typeof tenseId === 'object' && tenseId._id) {
    return tenseId._id.toString();
  }
  return tenseId.toString();
}

export function serializeStory(story) {
  return {
    _id: story._id.toString(),
    tenseId: tenseIdToString(story.tenseId),
    title: story.title,
    englishText: story.englishText,
    hindiText: story.hindiText,
    isDemo: story.isDemo,
    category: story.category ?? null,
    createdAt: story.createdAt,
  };
}

export function serializeTense(tense) {
  return {
    _id: tense._id.toString(),
    name: tense.name,
    description: tense.description,
    emoji: tense.emoji,
  };
}

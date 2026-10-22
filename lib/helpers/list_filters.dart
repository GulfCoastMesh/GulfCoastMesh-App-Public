enum ChatFilter { all, unread, dms, channels, rooms }

enum ChatSortMode { recent, alphabetical }

enum NodeCategoryFilter { favorites, contacts, repeaters, rooms }

ChatSortMode chatSortModeFromString(String value) {
  switch (value) {
    case 'alphabetical':
      return ChatSortMode.alphabetical;
    case 'recent':
    default:
      return ChatSortMode.recent;
  }
}

String chatSortModeToString(ChatSortMode mode) {
  switch (mode) {
    case ChatSortMode.recent:
      return 'recent';
    case ChatSortMode.alphabetical:
      return 'alphabetical';
  }
}

ChatFilter chatFilterFromString(String value) {
  switch (value) {
    case 'unread':
      return ChatFilter.unread;
    case 'dms':
      return ChatFilter.dms;
    case 'channels':
      return ChatFilter.channels;
    case 'rooms':
      return ChatFilter.rooms;
    case 'all':
    default:
      return ChatFilter.all;
  }
}

String chatFilterToString(ChatFilter filter) {
  switch (filter) {
    case ChatFilter.all:
      return 'all';
    case ChatFilter.unread:
      return 'unread';
    case ChatFilter.dms:
      return 'dms';
    case ChatFilter.channels:
      return 'channels';
    case ChatFilter.rooms:
      return 'rooms';
  }
}

NodeCategoryFilter nodeCategoryFilterFromString(String value) {
  switch (value) {
    case 'favorites':
      return NodeCategoryFilter.favorites;
    case 'repeaters':
      return NodeCategoryFilter.repeaters;
    case 'rooms':
      return NodeCategoryFilter.rooms;
    case 'contacts':
    default:
      return NodeCategoryFilter.contacts;
  }
}

String nodeCategoryFilterToString(NodeCategoryFilter filter) {
  switch (filter) {
    case NodeCategoryFilter.favorites:
      return 'favorites';
    case NodeCategoryFilter.contacts:
      return 'contacts';
    case NodeCategoryFilter.repeaters:
      return 'repeaters';
    case NodeCategoryFilter.rooms:
      return 'rooms';
  }
}

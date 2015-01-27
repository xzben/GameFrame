#include <stdlib.h>
#include <stdint.h>
#include "lua52.h"
#include <queue>

//support for lua 5.1 if use lua 5.1 please off this macro
#if 1
	#define	luaL_checkversion(a)
	#define lua_pushunsigned		lua_pushnumber
	#define lua_tounsigned			lua_tonumber
	#define lua_rawlen				lua_objlen
#endif


static int lua_tounsignedx(lua_State *L, int idx, int* isNum)
{
	*isNum = lua_isnumber(L, idx);
	if(*isNum != 1)
		return 0;
	return lua_tonumber ( L, idx);
}

typedef struct _TableNode {
    uint32_t key;
    int next;

    char flag; // 0: empty, 'n': non-terminator, 'o': terminator
    void* value;
} TableNode;

typedef struct _Table {
    int capacity;

    TableNode* node;
    TableNode* lastfree;
} Table;

inline static void
initnode(TableNode *node) {
    node->next = -1;

    node->flag = 0;
    node->value = NULL;
}

inline static int
tisnil(TableNode* node) {
    return node->flag == 0;
}

inline static TableNode*
tnode(Table *t, int index) {
    return t->node + index;
}

inline static int
tindex(Table *t, TableNode *node) {
    return node - t->node;
}

static TableNode*
mainposition(Table *t, uint32_t key) {
    return &t->node[(key & (t->capacity -1))];
}

static TableNode*
getfreenode(Table *t) {
    while(t->lastfree >= t->node) {
        if(tisnil(t->lastfree)) {
            return t->lastfree;
        }
        t->lastfree--;
    }
    return NULL;
}

static TableNode*
table_newkey(Table *t, uint32_t key);

static void
table_expand(Table *t) {
    int capacity = t->capacity;
    TableNode *node = t->node;

    t->capacity = t->capacity * 2;
    t->node = (TableNode*)calloc(t->capacity, sizeof(TableNode));
    int i;
    for(i=0; i<t->capacity; i++) {
        initnode(t->node + i);
    }
    t->lastfree = t->node + (t->capacity - 1);

    for(i=0; i< capacity; i++) {
        TableNode *old = node + i;
        if(tisnil(old)) {
            continue;
        }
        TableNode *new_node = table_newkey(t, old->key);
        new_node->flag = old->flag;
        new_node->value = old->value;
    }
    // free old node
    free(node);
}

/*
** inserts a new key into a hash table; first, check whether key's main
** position is free. If not, check whether colliding node is in its main
** position or not: if it is not, move colliding node to an empty place and
** put new key in its main position; otherwise (colliding node is in its main
** position), new key goes to an empty position.
*/
static TableNode*
table_newkey(Table *t, uint32_t key) {
    TableNode *mp = mainposition(t, key);
    if(!tisnil(mp)) {
        TableNode *n = getfreenode(t);
        if(n == NULL) {
            table_expand(t);
            return table_newkey(t, key);
        }
        TableNode *othern = mainposition(t, mp->key);
        if (othern != mp) {
            int mindex = tindex(t, mp);
            while(othern->next != mindex) {
                othern = tnode(t, othern->next);
            }
            othern->next = tindex(t, n);
            *n = *mp;
            initnode(mp);
        } else {
            n->next = mp->next;
            mp->next = tindex(t, n);
            mp = n;
        }
    }
    mp->key = key;
    mp->flag = 'n';
    return mp;
}

static TableNode*
table_get(Table *t, uint32_t key) {
    TableNode *n = mainposition(t, key);
    while(!tisnil(n)) {
        if(n->key == key) {
            return n;
        }
        if(n->next < 0) {
            break;
        }
        n = tnode(t, n->next);
    }
    return NULL;
}

static TableNode*
table_insert(Table *t, uint32_t key) {
    TableNode *node = table_get(t, key);
    if(node) {
        return node;
    }
    return table_newkey(t, key);
}

static Table*
table_new() {
    Table *t = (Table*)malloc(sizeof(Table));
    t->capacity = 1;

    t->node = (TableNode*)malloc(sizeof(TableNode));
    initnode(t->node);
    t->lastfree = t->node;
    return t;
}

static void
_dict_close(Table *t, bool free_root) {
	if(t == NULL) {
		return;
	}
	int i = 0;
	for(i=0; i<t->capacity; i++) {
		TableNode *node = t->node + i;

		if((Table*)node->value != NULL) {
			_dict_close((Table*)node->value, true);
		}
	}
	free(t->node);
	if(free_root)
		free(t);
}

static void 
_disct_free(Table *t){
	std::queue<Table*> free_queue;

	free_queue.push(t);
	while(!free_queue.empty())
	{
		Table* tmp = free_queue.front();
		free_queue.pop();

		for(int i = 0; i < tmp->capacity; i++)
		{
			TableNode* node = tmp->node + i;
			if(node->value != NULL)
				free_queue.push((Table*)node->value);
		}
		free(tmp->node);
		if(tmp != t)
			free(tmp);
	}

}

static void
_dict_dump(Table *t, int indent) {
    if(t == NULL) {
        return;
    }
    int i = 0;
    for(i=0; i<t->capacity; i++) {
        TableNode *node = t->node + i;
        printf("%*s", indent, " ");
        if(node->flag != 0) {
            printf("0x%x\n", node->key);
            _dict_dump((Table*)node->value, indent + 8);
        } else {
            printf("%s\n", "nil");
        }
    }
}

static int
_dict_insert(lua_State *L, Table* dict) {
    if(!lua_istable(L, -1)) {
        return 0;
    }

    size_t len = lua_rawlen(L, -1);
    size_t i;
    uint32_t rune;
    TableNode *node = NULL;
    for(i=1; i<=len; i++) {
        lua_rawgeti(L, -1, i);
        int isnum;
		rune = lua_tounsignedx(L, -1, &isnum);
        lua_pop(L, 1);

        if(!isnum) {
            return 0;
        }

        Table *tmp;
        if(node == NULL) {
            tmp = dict;
        } else {
            if(node->value == NULL) {
                node->value = table_new();
            } 
            tmp = (Table*)node->value;
        }
        node = table_insert(tmp, rune);
    }
    if(node) {
        node->flag = 'o';
    }
    return 1;
}

#define check_crab_obj(L, index)			(Table*) luaL_checkudata((L), (index), "crab.object")
#define set_crab_obj_flag(L)		do{ luaL_getmetatable((L), "crab.object");lua_setmetatable((L), -2); }while(0)

static int new_crab_obj(lua_State *L){
	luaL_checktype(L, 1, LUA_TTABLE);//检查第一个参数是否是table

	Table *dict = (Table*)lua_newuserdata(L, sizeof(Table));
	set_crab_obj_flag(L);
	dict->capacity = 1;

	dict->node = (TableNode*)malloc(sizeof(TableNode));
	initnode(dict->node);
	dict->lastfree = dict->node;
	
	size_t len = lua_rawlen(L, 1);
	size_t i;
	for(i=1;i<=len;i++) {
		lua_rawgeti(L, 1, i);
		if(!_dict_insert(L, dict)) {
			_disct_free(dict);
			return luaL_error(L, "illegal parameters in table index %d", i);
		}
		lua_pop(L, 1);
	}
	//_dict_dump(dict, 0);
	// don't close old g_dict, avoid crash
	return 1;
}

static int filter_word(lua_State *L)
{
	Table* dict = check_crab_obj(L, 1);

	luaL_checktype(L, 2, LUA_TTABLE);
	size_t len = lua_rawlen(L, 2);
	size_t i,j;
	int flag = 0;
	for(i=1;i<=len;) {
		TableNode *node = NULL;
		int step = 0;
		for(j=i;j<=len;j++) {
			lua_rawgeti(L, 2, j);
			uint32_t rune = lua_tounsigned(L, -1);
			lua_pop(L, 1);

			if(node == NULL) {
				node = table_get(dict, rune);
			} else {
				node = table_get((Table*)node->value, rune);
			}

			if(node && node->flag == 'o') step = j - i + 1;
			if(!(node && node->value)) break;
		}
		if(step > 0) {
			for(j=0;j<step;j++) {
				lua_pushinteger(L, '*');
				lua_rawseti(L, 2, i+j);
			}
			flag = 1;
			i = i + step;
		} else {
			i++;
		}
	}
	lua_pushboolean(L, flag);
	return 1;
}

static int delete_crab_obj(lua_State *L)
{
	Table* dict = check_crab_obj(L, 1);
	_disct_free(dict);

	return 1;
}

// interface
LUALIB_API int luaopen_crab_c(lua_State *L) {
    luaL_checkversion(L);

    luaL_Reg l[] = {
		{"new_crab_obj", new_crab_obj},
		{"filter_word", filter_word},
		{"delete_crab_obj", delete_crab_obj},
        {NULL, NULL}
    };

	//为 user data 设置 __gc
	luaL_newmetatable(L, "crab.object");
	lua_pushcfunction(L, delete_crab_obj);
	lua_setfield(L,-2,"__gc");

	luaL_register(L, "crab.core", l);
    return 1;
}


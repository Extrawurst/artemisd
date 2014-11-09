module artemisd.entitymanager;

import std.bitmanip;
import artemisd.utils.bag;
import artemisd.entity;
import artemisd.manager;
import artemisd.world;
import artemisd.utils.type;

class EntityManager : Manager
{
    mixin TypeDecl;

private:
    Bag!Entity entities;
    BitArray disabled_;

    int active;
    long added_;
    long created;
    long deleted_;

    IdentifierPool identifierPool;

public:
    this()
    {
        entities = new Bag!Entity();
        identifierPool = new IdentifierPool();
    }

    protected override void initialize()
    {
    }

    Entity createEntityInstance()
    {
        Entity e = new Entity(world, identifierPool.checkOut());
        created++;
        return e;
    }

    override void added(Entity e)
    {
        active++;
        added_++;
        entities.set(e.getId(), e);
    }

    override void enabled(Entity e)
    {
        auto eId = e.getId();
        if (disabled_.length <= eId)
            disabled_.length = eId + 1;
        disabled_[e.getId()] = 0;
    }

    override void disabled(Entity e)
    {
        auto eId = e.getId();
        if (disabled_.length <= eId)
            disabled_.length = eId + 1;
        disabled_[e.getId()] = 1;
    }

    override void deleted(Entity e)
    {
        entities.set(e.getId(), null);
        auto eId = e.getId();
        if (disabled_.length <= eId)
            disabled_.length = eId + 1;
        disabled_[e.getId()] = 0;
        identifierPool.checkIn(e.getId());

        active--;
        deleted_++;
    }

    bool isActive(int entityId)
    {
        return entities.get(entityId) !is null;
    }

    bool isEnabled(int entityId)
    {
        return !disabled_[entityId];
    }

    Entity getEntity(int entityId)
    {
        return entities.get(entityId);
    }

    int getActiveEntityCount()
    {
        return active;
    }

    long getTotalCreated()
    {
        return created;
    }

    long getTotalAdded()
    {
        return added_;
    }

    long getTotalDeleted()
    {
        return deleted_;
    }

    private class IdentifierPool
    {
        private Bag!int ids;
        private int nextAvailableId;

        this()
        {
            ids = new Bag!int();
        }

        int checkOut()
        {
            if(ids.size() > 0)
            {
                return ids.removeLast();
            }
            return nextAvailableId++;
        }

        void checkIn(int id)
        {
            ids.add(id);
        }
    }
}

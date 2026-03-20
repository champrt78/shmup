-- Collision detection

local Collision = {}

-- AABB overlap
function Collision.aabb(ax, ay, aw, ah, bx, by, bw, bh)
    return ax - aw/2 < bx + bw/2 and
           ax + aw/2 > bx - bw/2 and
           ay - ah/2 < by + bh/2 and
           ay + ah/2 > by - bh/2
end

-- Circle vs AABB (player hitbox vs enemy/bullet rect)
function Collision.circleRect(cx, cy, cr, rx, ry, rw, rh)
    local closestX = math.max(rx - rw/2, math.min(cx, rx + rw/2))
    local closestY = math.max(ry - rh/2, math.min(cy, ry + rh/2))
    local dx = cx - closestX
    local dy = cy - closestY
    return (dx*dx + dy*dy) < (cr*cr)
end

return Collision

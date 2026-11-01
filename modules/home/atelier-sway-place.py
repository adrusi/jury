"""Puts atelier's agent windows on the "atelier" workspace: Claude Code
sessions in a tabbed column on the left, their Firefox windows in a tabbed
column on the right.

    atelier-sway-place agents APP_ID      every window with APP_ID not yet placed
    atelier-sway-place browser FX_ID      the Firefox window titled "[fx:FX_ID] …"
                                          (firefox-sway-favicon's title prefix),
                                          once it has that title
"""

import json
import subprocess
import sys
import time

WORKSPACE = "atelier"


def sway(*args):
    out = subprocess.run(["swaymsg", *args], capture_output=True, text=True).stdout
    return json.loads(out) if out.strip() else None


def tree():
    return sway("-t", "get_tree")


def walk(node, parent=None):
    yield node, parent
    for child in node.get("nodes", []) + node.get("floating_nodes", []):
        yield from walk(child, node)


def workspace(root):
    for node, _ in walk(root):
        if node.get("type") == "workspace" and node.get("name") == WORKSPACE:
            return node
    return None


def leaves(node):
    return [n for n, _ in walk(node) if n.get("type") == "con" and not n.get("nodes")]


def parent_of(root, con_id):
    for node, parent in walk(root):
        if node.get("id") == con_id:
            return parent
    return None


def is_agent(leaf, app_id):
    return leaf.get("app_id") == app_id


def is_browser(leaf):
    return (leaf.get("name") or "").startswith("[fx:")


def run(*commands):
    sway(";".join(commands))


def place(con_id, mine, left):
    """Moves con_id into the column of windows that `mine` picks out on the
    workspace, making that column (tabbed, on the left or right) if there
    isn't one yet."""
    root = tree()
    ws = workspace(root)
    if ws is not None:
        if any(n.get("id") == con_id for n in leaves(ws)):
            parent = parent_of(root, con_id)
            if parent is not None and parent.get("layout") == "tabbed" and parent.get("type") == "con":
                return  # already in its column
        same = [n for n in leaves(ws) if mine(n) and n["id"] != con_id]
        if same:
            target = same[-1]["id"]
            run(
                f"[con_id={target}] mark --add _atelier_place",
                f"[con_id={con_id}] move container to mark _atelier_place",
                f"[con_id={target}] unmark _atelier_place",
            )
            return
    # The first of its kind: onto the workspace, out of the other column,
    # and into a tabbed column of its own.
    run(f"[con_id={con_id}] move container to workspace {WORKSPACE}")
    for _ in range(8):
        root = tree()
        ws = workspace(root)
        parent = parent_of(root, con_id)
        if ws is None or parent is None or parent.get("id") == ws.get("id"):
            break
        run(f"[con_id={con_id}] move {'left' if left else 'right'}")
    run(f"[con_id={con_id}] splitv", f"[con_id={con_id}] layout tabbed")


def main():
    kind, key = sys.argv[1], sys.argv[2]
    if kind == "agents":
        mine = lambda n: is_agent(n, key)
        root = tree()
        ws = workspace(root)
        placed = {n["id"] for n in leaves(ws)} if ws else set()
        for leaf in leaves(root):
            if is_agent(leaf, key) and leaf["id"] not in placed:
                place(leaf["id"], mine, left=True)
    elif kind == "browser":
        prefix = f"[fx:{key}] "
        deadline = time.time() + 15
        while time.time() < deadline:
            found = [n for n in leaves(tree()) if (n.get("name") or "").startswith(prefix)]
            if found:
                place(found[0]["id"], is_browser, left=False)
                return
            time.sleep(0.2)
        print(f"atelier-sway-place: no window titled {prefix!r}", file=sys.stderr)
        sys.exit(1)
    else:
        print(__doc__, file=sys.stderr)
        sys.exit(2)


if __name__ == "__main__":
    main()

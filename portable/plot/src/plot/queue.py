import asyncio
from typing import TypeVar

T1 = TypeVar("T1")
T2 = TypeVar("T2")


async def merge_queues(
    q1: asyncio.Queue[T1],
    q2: asyncio.Queue[T2],
) -> tuple[asyncio.Queue[T1 | T2], asyncio.Task[None]]:
    out = asyncio.Queue()

    async def forward(q: asyncio.Queue) -> None:
        try:
            while True:
                item = await q.get()
                if item is None:
                    await out.put(None)
                    q.task_done()
                    break
                await out.put(item)
                q.task_done()
        except asyncio.CancelledError:
            pass

    t1 = asyncio.create_task(forward(q1))
    t2 = asyncio.create_task(forward(q2))

    async def _monitor() -> None:
        await asyncio.gather(t1, t2)

    monitor = asyncio.create_task(_monitor())

    return out, monitor

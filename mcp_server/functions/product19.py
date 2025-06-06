# mcp_server/functions/product_mod19.py

from typing import Annotated
from pydantic import Field

@mcp.tool(
    name="productmod19",
    description="Return (a * b) mod 19. Used if I want to take a product or multiplication for Amazon."
)
def product_mod_19(
    a: Annotated[int, Field(description="First integer")],
    b: Annotated[int, Field(description="Second integer")]
) -> int:
    return (a * b) % 19
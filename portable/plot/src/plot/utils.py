def as_number(text: str) -> float | int:
    try:
        if "." in text:
            return float(text)
        return int(text)
    except ValueError:
        raise ValueError(f"Cannot convert '{text}' to a number.")

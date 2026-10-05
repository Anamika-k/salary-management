// "Showing 26–50 of 10,000" with previous/next buttons, driven by the API's meta.
import { ChevronLeft, ChevronRight } from "lucide-react";
import Button from "./Button";

export default function Pagination({ meta, onPageChange }) {
  if (!meta || meta.total_count === 0) return null;
  const { current_page: page, total_pages: pages, total_count: total, per_page: perPage } = meta;
  const from = (page - 1) * perPage + 1;
  const to = Math.min(page * perPage, total);

  return (
    <div className="flex items-center justify-between border-t border-zinc-100 px-4 py-3 text-sm text-zinc-500">
      <p className="tabular">
        Showing <span className="font-medium text-zinc-900">{from.toLocaleString()}–{to.toLocaleString()}</span> of{" "}
        <span className="font-medium text-zinc-900">{total.toLocaleString()}</span>
      </p>
      <div className="flex items-center gap-1.5">
        <span className="mr-2 hidden tabular sm:inline">Page {page} of {pages}</span>
        <Button variant="secondary" size="icon" aria-label="Previous page" disabled={page <= 1} onClick={() => onPageChange(page - 1)}>
          <ChevronLeft className="h-4 w-4" />
        </Button>
        <Button variant="secondary" size="icon" aria-label="Next page" disabled={page >= pages} onClick={() => onPageChange(page + 1)}>
          <ChevronRight className="h-4 w-4" />
        </Button>
      </div>
    </div>
  );
}

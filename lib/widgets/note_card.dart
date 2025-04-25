import 'package:flutter/material.dart';
import 'package:book_tracker/models/book.dart';
import 'package:intl/intl.dart';

class NoteCard extends StatelessWidget {
  final Note note;
  final Function()? onDelete;

  const NoteCard({
    super.key,
    required this.note,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: note.isHighlight 
            ? colorScheme.primary.withOpacity(0.08)
            : colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: note.isHighlight
              ? colorScheme.primary.withOpacity(0.3)
              : Colors.grey.withOpacity(0.2),
          width: note.isHighlight ? 1 : 0.5,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            if (note.isHighlight)
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                width: 4,
                child: Container(
                  color: colorScheme.primary,
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: note.isHighlight
                              ? colorScheme.primary.withOpacity(0.2)
                              : Colors.grey.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              note.isHighlight ? Icons.format_quote : Icons.note,
                              size: 14,
                              color: note.isHighlight
                                  ? colorScheme.primary
                                  : Colors.grey.shade700,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              note.isHighlight ? 'Highlight' : 'Note',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: note.isHighlight
                                    ? colorScheme.primary
                                    : Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (note.pageNumber > 0) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Page ${note.pageNumber}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ),
                      ],
                      const Spacer(),
                      Text(
                        DateFormat('MMM d, yyyy').format(note.createdAt),
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurface.withOpacity(0.6),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: note.isHighlight
                          ? Colors.white.withOpacity(0.6)
                          : Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: note.isHighlight
                            ? colorScheme.primary.withOpacity(0.2)
                            : Colors.grey.withOpacity(0.1),
                                                    width: 0.5,
                      ),
                    ),
                    child: Text(
                      note.content,
                      style: note.isHighlight
                          ? textTheme.bodyMedium?.copyWith(
                              fontStyle: FontStyle.italic,
                              color: colorScheme.onSurface,
                              height: 1.5,
                              letterSpacing: 0.2,
                            )
                          : textTheme.bodyMedium?.copyWith(
                              height: 1.5,
                            ),
                    ),
                  ),
                  if (onDelete != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton.icon(
                          onPressed: onDelete,
                          icon: const Icon(Icons.delete_outline, size: 16),
                          label: const Text('Delete'),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            foregroundColor: Colors.red.shade700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

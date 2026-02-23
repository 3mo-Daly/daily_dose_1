import 'dart:io';
import 'package:flutter/material.dart';
import '../../../../models/medicine_model.dart';
import 'package:intl/intl.dart';

class MedicineCard extends StatelessWidget {
  final Medicine medicine;
  final VoidCallback? onTaken;
  final VoidCallback? onUncheck;
  final bool isSelected;
  final VoidCallback? onLongPress;
  final VoidCallback? onTap;

  const MedicineCard({
    super.key,
    required this.medicine,
    this.onTaken,
    this.onUncheck,
    this.isSelected = false,
    this.onLongPress,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Status Logic
    final now = DateTime.now();
    final startTime = medicine.startTime;
    final isTaken = medicine.isTaken;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    bool isFuture = now.isBefore(startTime);
    bool isPassed = now.isAfter(startTime.add(const Duration(minutes: 30)));
    bool isInProgress = !isFuture && !isPassed;

    // Determine Status
    // 0: Future, 1: InProgress, 2: Passed, 3: Done
    // Logic:
    // If isTaken -> Done.
    // Else -> Time based.

    // Update Status logic based on specific requirements
    // Medicine is in progress if it's within 30 minutes BEFORE the start time, up until 30 minutes after.
    // The user wants it to appear 30 mins before, or if it was missed.
    bool canTake = isInProgress || isPassed;

    Color? cardColor;
    Color statusColor;
    IconData statusIcon;
    String statusText;

    if (isTaken) {
      // DONE
      statusText = 'Taken';
      statusColor = isDarkMode ? Colors.grey[500]! : Colors.grey; // Muted color for taken
      statusIcon = Icons.check_circle;
      cardColor = isDarkMode
          ? Colors.grey[800]?.withValues(alpha: 0.5)
          : Colors.grey[300];
    } else if (isPassed) {
      // PASSED
      statusText = 'Missed';
      statusColor = isDarkMode ? Colors.red[400]! : Colors.red;
      statusIcon = Icons.error_outline;
      cardColor = isDarkMode
          ? Colors.red[900]?.withValues(alpha: 0.6)
          : Colors.red[50];
    } else if (isInProgress) {
      // IN PROGRESS
      statusText = 'Time to take';
      statusColor = isDarkMode ? Colors.orange[400]! : Colors.orange;
      statusIcon = Icons.access_time_filled;
      cardColor = isDarkMode
          ? Colors.orange[900]?.withValues(alpha: 0.6)
          : Colors.orange[50];
    } else {
      // FUTURE
      statusText = 'Upcoming';
      statusColor = isDarkMode ? Colors.grey[400]! : Colors.grey;
      statusIcon = Icons.schedule;
      cardColor = isDarkMode ? Theme.of(context).colorScheme.surfaceContainerHighest : null; // Default surface color
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: isSelected && !isTaken
          ? Theme.of(context).colorScheme.primaryContainer
          : cardColor,
      // Add a visual dashed border or opacity if taken, or a solid border if selected
      elevation: isTaken ? 0 : (isSelected ? 6 : 3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : (isTaken ? Colors.grey.withOpacity(0.5) : Colors.transparent),
          width: isSelected ? 2 : 1,
          style: isTaken && !isSelected ? BorderStyle.solid : BorderStyle.solid,
        ),
      ),
      child: InkWell(
        onLongPress: onLongPress,
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Opacity(
          opacity: isTaken
              ? 0.6
              : 1.0, // Make the whole card look disabled/done
          child: ListTile(
            leading: medicine.imagePath != null
                ? CircleAvatar(
                    backgroundImage: FileImage(File(medicine.imagePath!)),
                  )
                : CircleAvatar(
                    backgroundColor: statusColor.withValues(alpha: 0.2),
                    child: Icon(Icons.medication_rounded, color: statusColor),
                  ),
            title: Text(
              medicine.name,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                decoration: isTaken ? TextDecoration.lineThrough : null,
                color: isTaken ? Colors.grey : null,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${medicine.dosage} • ${_formatTime()}',
                  style: TextStyle(
                    decoration: isTaken ? TextDecoration.lineThrough : null,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(statusIcon, size: 14, color: statusColor),
                    const SizedBox(width: 4),
                    Text(
                      statusText,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            // Only show the trailing checkmark button if it's NOT taken, AND it can be taken (isInProgress or isPassed)
            trailing: (!isTaken && canTake)
                ? IconButton(
                    icon: const Icon(Icons.circle_outlined),
                    onPressed: onTaken,
                    color: Theme.of(context).colorScheme.primary,
                  )
                : (isTaken
                      ? IconButton(
                          icon: const Icon(
                            Icons.check_circle,
                            color: Colors.green,
                          ),
                          onPressed: onUncheck,
                        )
                      : null), // Show nothing if it's in the future and not taken
          ),
        ),
      ),
    );
  }

  String _formatTime() {
    // Use the specific instance time (which HomeCubit has updated for this occurrence)
    return DateFormat.jm().format(medicine.startTime);
  }
}

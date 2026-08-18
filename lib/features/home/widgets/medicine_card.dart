import 'dart:io';
import 'package:flutter/material.dart';
import '../../../../models/medicine_model.dart';
import 'package:intl/intl.dart';
import 'package:daily_dose/l10n/app_localizations.dart';

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
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final loc = AppLocalizations.of(context)!;

    // SINGLE SOURCE OF TRUTH — resolved fresh on every build from the live
    // theme. Because there is no manual `isDark ? light : dark` branching, a
    // theme toggle can never leave a card inverted or one step behind: the
    // background and the text/icons always come from the same Theme snapshot.
    final Color baseSurface = theme.cardTheme.color ?? cs.surface;
    final Color onSurface = cs.onSurface;

    // --- Time-based status ---------------------------------------------------
    final now = DateTime.now();
    final startTime = medicine.startTime;
    final isTaken = medicine.isTaken;

    final bool isFuture = now.isBefore(startTime);
    final bool isPassed = now.isAfter(startTime.add(const Duration(minutes: 30)));
    final bool isInProgress = !isFuture && !isPassed;
    final bool canTake = isInProgress || isPassed;

    // One accent hue per status, each legible on BOTH the light and dark card
    // surface, so no brightness-specific colour picking is needed.
    final Color accent;
    final IconData statusIcon;
    final String statusText;
    if (isTaken) {
      accent = cs.onSurfaceVariant;
      statusIcon = Icons.check_circle;
      statusText = loc.taken;
    } else if (isPassed) {
      accent = cs.error; // theme-aware red
      statusIcon = Icons.error_outline;
      statusText = loc.missed;
    } else if (isInProgress) {
      accent = const Color(0xFFF59E0B); // amber "due now" — reads on both modes
      statusIcon = Icons.access_time_filled;
      statusText = loc.timeToTake;
    } else {
      accent = cs.onSurfaceVariant;
      statusIcon = Icons.schedule;
      statusText = loc.upcoming;
    }

    // Background = the theme surface, optionally given a faint status tint by
    // blending the accent OVER it. alphaBlend keeps it opaque and works the
    // same in light and dark because the base is already theme-correct.
    final Color cardColor;
    if (isSelected && !isTaken) {
      cardColor = cs.primaryContainer;
    } else if (isPassed && !isTaken) {
      cardColor = Color.alphaBlend(accent.withValues(alpha: 0.10), baseSurface);
    } else if (isInProgress && !isTaken) {
      cardColor = Color.alphaBlend(accent.withValues(alpha: 0.12), baseSurface);
    } else {
      cardColor = baseSurface;
    }

    final Color titleColor =
        isTaken ? onSurface.withValues(alpha: 0.5) : onSurface;
    final Color subtitleColor = isTaken
        ? cs.onSurfaceVariant.withValues(alpha: 0.7)
        : cs.onSurfaceVariant;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: cardColor,
      elevation: isTaken ? 0 : (isSelected ? 6 : 3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected
              ? cs.primary
              : (isTaken ? cs.outlineVariant : Colors.transparent),
          width: isSelected ? 2 : 1,
        ),
      ),
      child: InkWell(
        onLongPress: onLongPress,
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Opacity(
          opacity: isTaken ? 0.65 : 1.0, // "done" cards read as disabled
          child: ListTile(
            leading: medicine.imagePath != null
                ? CircleAvatar(
                    backgroundImage: FileImage(File(medicine.imagePath!)),
                  )
                : CircleAvatar(
                    backgroundColor: accent.withValues(alpha: 0.15),
                    child: Icon(Icons.medication_rounded, color: accent),
                  ),
            title: Text(
              medicine.name,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: titleColor,
                decoration: isTaken ? TextDecoration.lineThrough : null,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${medicine.dosage} • ${_formatTime(context)}',
                  style: TextStyle(
                    color: subtitleColor,
                    decoration: isTaken ? TextDecoration.lineThrough : null,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(statusIcon, size: 14, color: accent),
                    const SizedBox(width: 4),
                    Text(
                      statusText,
                      style: TextStyle(
                        color: accent,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            // Take button only while actionable; check button once taken.
            trailing: (!isTaken && canTake)
                ? IconButton(
                    icon: const Icon(Icons.circle_outlined),
                    onPressed: onTaken,
                    color: cs.primary,
                  )
                : (isTaken
                      ? IconButton(
                          icon: Icon(Icons.check_circle, color: cs.primary),
                          onPressed: onUncheck,
                        )
                      : null),
          ),
        ),
      ),
    );
  }

  String _formatTime(BuildContext context) {
    // Use the specific instance time (which HomeCubit has updated for this
    // occurrence). Locale-aware so Arabic renders Arabic-Indic digits and ص/م.
    final localeName = Localizations.localeOf(context).languageCode;
    return DateFormat.jm(localeName).format(medicine.startTime);
  }
}

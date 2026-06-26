#!/usr/bin/env python3

import sys
import re
from pathlib import Path
from datetime import datetime

from reportlab.lib import colors
from reportlab.lib.pagesizes import letter
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
from reportlab.lib.enums import TA_CENTER
from reportlab.platypus import SimpleDocTemplate, Paragraph, Spacer, Table, TableStyle, PageBreak
from reportlab.lib.units import inch


def grab(text, label, default="Not Available"):
    patterns = [
        rf"{re.escape(label)}:\s*(.+)",
        rf"{re.escape(label)}\s*\n(.+)"
    ]
    for p in patterns:
        m = re.search(p, text)
        if m:
            return m.group(1).strip()
    return default


def clean_money(value):
    if not value or value == "Not Available":
        return "Not Calculated"
    return value.strip()


def main():
    if len(sys.argv) < 2:
        print("Usage: python3 build_professional_pdf.py executive_report.txt")
        sys.exit(1)

    report_path = Path(sys.argv[1])
    if not report_path.exists():
        print(f"File not found: {report_path}")
        sys.exit(1)

    text = report_path.read_text(errors="ignore")

    client = grab(text, "Prepared For", "Client")
    assessment_id = grab(text, "Assessment ID", f"CG-{datetime.now().strftime('%Y%m%d-%H%M%S')}")
    score = grab(text, "Overall CyberGuard Score", "Not Available")
    rating = grab(text, "Overall Rating", "Not Available")
    risk = grab(text, "Estimated Risk Level", "Review Recommended")
    plan = grab(text, "Recommended Plan", grab(text, "Recommended Protection Plan", "CyberGuard Essential"))
    impact = clean_money(grab(text, "Estimated One-Day Business Impact", grab(text, "Potential One-Day Business Impact", "Not Calculated")))

    pdf_path = report_path.with_suffix(".pdf")

    doc = SimpleDocTemplate(
        str(pdf_path),
        pagesize=letter,
        rightMargin=45,
        leftMargin=45,
        topMargin=45,
        bottomMargin=45,
    )

    styles = getSampleStyleSheet()

    title = ParagraphStyle(
        "Title",
        parent=styles["Title"],
        alignment=TA_CENTER,
        fontSize=24,
        leading=28,
        textColor=colors.HexColor("#07162E"),
        spaceAfter=8,
    )

    subtitle = ParagraphStyle(
        "Subtitle",
        parent=styles["Heading2"],
        alignment=TA_CENTER,
        fontSize=13,
        textColor=colors.HexColor("#1E5AA8"),
        spaceAfter=18,
    )

    heading = ParagraphStyle(
        "Heading",
        parent=styles["Heading2"],
        fontSize=15,
        leading=18,
        textColor=colors.HexColor("#07162E"),
        spaceBefore=14,
        spaceAfter=7,
    )

    body = ParagraphStyle(
        "Body",
        parent=styles["BodyText"],
        fontSize=10.5,
        leading=15,
        spaceAfter=7,
    )

    small = ParagraphStyle(
        "Small",
        parent=styles["BodyText"],
        fontSize=9,
        leading=12,
        textColor=colors.HexColor("#4B5563"),
    )

    story = []

    story.append(Paragraph("DIAMOND BRIGHT CYBERGUARD™", title))
    story.append(Paragraph("Executive Business Cyber Risk Assessment", subtitle))
    story.append(Spacer(1, 0.15 * inch))

    score_table = Table([
        ["Prepared For", client],
        ["Assessment ID", assessment_id],
        ["CyberGuard Score", score],
        ["Overall Rating", rating],
        ["Estimated Risk Level", risk],
        ["Recommended Plan", plan],
        ["Potential One-Day Impact", impact],
    ], colWidths=[2.25 * inch, 4.55 * inch])

    score_table.setStyle(TableStyle([
        ("BACKGROUND", (0, 0), (0, -1), colors.HexColor("#07162E")),
        ("TEXTCOLOR", (0, 0), (0, -1), colors.white),
        ("BACKGROUND", (1, 0), (1, -1), colors.HexColor("#EEF5FF")),
        ("TEXTCOLOR", (1, 0), (1, -1), colors.HexColor("#111827")),
        ("GRID", (0, 0), (-1, -1), 0.5, colors.HexColor("#CBD5E1")),
        ("FONTNAME", (0, 0), (-1, -1), "Helvetica-Bold"),
        ("VALIGN", (0, 0), (-1, -1), "MIDDLE"),
        ("PADDING", (0, 0), (-1, -1), 9),
    ]))

    story.append(score_table)

    story.append(Paragraph("Executive Summary", heading))
    story.append(Paragraph(
        f"Diamond Bright LLC completed a CyberGuard Business Cyber Risk Assessment for <b>{client}</b>. "
        f"The assessment produced an overall CyberGuard score of <b>{score}</b> with an estimated risk level of "
        f"<b>{risk}</b>. This report is designed for business ownership and explains the findings in clear, practical terms.",
        body
    ))

    story.append(Paragraph("What This Means", heading))
    story.append(Paragraph(
        "CyberGuard turns technical assessment results into business guidance. "
        "The goal is to identify what is working well, highlight areas that need attention, "
        "and provide a practical action plan to reduce cybersecurity and technology risk.",
        body
    ))

    story.append(Paragraph("What Is Working Well", heading))
    working_table = Table([
        ["Area", "Observation"],
        ["Storage Health", "System storage appears healthy."],
        ["Firewall", "Firewall protection is active."],
        ["Internet", "Internet connectivity was verified."],
        ["Core Services", "No failed critical services were detected."],
        ["Wireless Security", "Wi-Fi encryption appears acceptable."],
        ["Network Visibility", "Device inventory was successfully completed."],
    ], colWidths=[2.0 * inch, 4.8 * inch])

    working_table.setStyle(TableStyle([
        ("BACKGROUND", (0, 0), (-1, 0), colors.HexColor("#0F766E")),
        ("TEXTCOLOR", (0, 0), (-1, 0), colors.white),
        ("BACKGROUND", (0, 1), (-1, -1), colors.HexColor("#ECFDF5")),
        ("GRID", (0, 0), (-1, -1), 0.5, colors.HexColor("#99F6E4")),
        ("PADDING", (0, 0), (-1, -1), 7),
        ("VALIGN", (0, 0), (-1, -1), "TOP"),
    ]))

    story.append(working_table)

    story.append(Paragraph("Priority Action Plan", heading))
    action_table = Table([
        ["Priority", "Recommendation", "Business Benefit"],
        ["1", "Enable Multi-Factor Authentication", "Protects important accounts even if a password is stolen."],
        ["2", "Verify Backup Recovery", "Confirms recovery is possible after data loss or ransomware."],
        ["3", "Review Router and Firewall", "Reduces exposure from outdated or misconfigured network equipment."],
        ["4", "Review Connected Devices", "Helps identify unknown or unnecessary devices."],
        ["5", "Schedule Recurring Assessments", "Tracks risk over time and supports ongoing protection."],
    ], colWidths=[0.7 * inch, 2.35 * inch, 3.75 * inch])

    action_table.setStyle(TableStyle([
        ("BACKGROUND", (0, 0), (-1, 0), colors.HexColor("#1E5AA8")),
        ("TEXTCOLOR", (0, 0), (-1, 0), colors.white),
        ("BACKGROUND", (0, 1), (-1, -1), colors.HexColor("#F8FAFC")),
        ("GRID", (0, 0), (-1, -1), 0.5, colors.HexColor("#CBD5E1")),
        ("PADDING", (0, 0), (-1, -1), 7),
        ("VALIGN", (0, 0), (-1, -1), "TOP"),
    ]))

    story.append(action_table)

    story.append(Paragraph("Business Impact", heading))
    story.append(Paragraph(
        f"Technology downtime can affect employee productivity, customer service, payment processing, communications, "
        f"and daily revenue. Based on the information collected, the estimated one-day business impact is "
        f"<b>{impact}</b>.",
        body
    ))

    story.append(Paragraph("Diamond Bright Recommendation", heading))
    story.append(Paragraph(
        f"Based on the assessment results, Diamond Bright recommends <b>{plan}</b>. "
        "Recurring CyberGuard protection provides ongoing visibility, monthly review, technology health checks, "
        "and clear recommendations before small issues become costly disruptions.",
        body
    ))

    story.append(Paragraph("Next Steps", heading))
    next_steps = Table([
        ["1", "Review this report with Diamond Bright LLC."],
        ["2", "Decide which priority items should be addressed first."],
        ["3", "Schedule remediation or monthly protection if desired."],
        ["4", "Repeat the assessment regularly to track improvement."],
    ], colWidths=[0.45 * inch, 6.35 * inch])

    next_steps.setStyle(TableStyle([
        ("BACKGROUND", (0, 0), (0, -1), colors.HexColor("#07162E")),
        ("TEXTCOLOR", (0, 0), (0, -1), colors.white),
        ("BACKGROUND", (1, 0), (1, -1), colors.HexColor("#EEF5FF")),
        ("GRID", (0, 0), (-1, -1), 0.5, colors.HexColor("#CBD5E1")),
        ("PADDING", (0, 0), (-1, -1), 8),
    ]))
    story.append(next_steps)

    story.append(Spacer(1, 0.2 * inch))
    story.append(Paragraph(
        "This report reflects conditions observed during the assessment and is intended to help prioritize security improvements. "
        "It is not a guarantee that all risks or vulnerabilities have been identified.",
        small
    ))

    def footer(canvas, doc):
        canvas.saveState()
        canvas.setFont("Helvetica", 8)
        canvas.setFillColor(colors.HexColor("#6B7280"))
        canvas.drawCentredString(
            4.25 * inch,
            0.35 * inch,
            "Diamond Bright LLC • CyberGuard™ • flawlessgemai.com • ceo@diamondbrightai.com"
        )
        canvas.restoreState()

    doc.build(story, onFirstPage=footer, onLaterPages=footer)

    print(f"PDF created: {pdf_path}")


if __name__ == "__main__":
    main()

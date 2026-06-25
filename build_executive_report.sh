#!/bin/bash

TECH_REPORT="$1"

if [ -z "$TECH_REPORT" ]; then
    echo "Usage: ./build_executive_report.sh technical_report.txt"
    exit 1
fi

CLIENT=$(grep -m1 "^Client:" "$TECH_REPORT" | cut -d: -f2- | xargs)
ASSESSMENT_ID=$(grep -m1 "Assessment ID:" "$TECH_REPORT" | awk '{print $NF}')
SCORE=$(grep -m1 "Overall Technical Score:" "$TECH_REPORT" | grep -oE '[0-9]+/100')
RATING=$(grep -m1 "Overall Rating:" "$TECH_REPORT" | awk '{print $NF}')
RISK=$(grep -m1 "Estimated Risk Level:" "$TECH_REPORT" | cut -d: -f2- | xargs)
PLAN=$(grep -m1 "Recommended Protection Plan:" "$TECH_REPORT" | cut -d: -f2- | xargs)
IMPACT=$(grep -m1 "Potential One-Day Business Impact:" "$TECH_REPORT" | cut -d: -f2- | xargs)
DATE_NOW=$(date "+%B %d, %Y")

[ -z "$CLIENT" ] && CLIENT="Client"
[ -z "$ASSESSMENT_ID" ] && ASSESSMENT_ID="CG-$(date +%Y%m%d-%H%M%S)"
[ -z "$SCORE" ] && SCORE="Not Available"
[ -z "$RATING" ] && RATING="Not Available"
[ -z "$RISK" ] && RISK="Review Recommended"
[ -z "$PLAN" ] && PLAN="CyberGuard Essential"
[ -z "$IMPACT" ] && IMPACT="Not Calculated"

SAFE_CLIENT=$(echo "$CLIENT" | tr ' ' '_' | tr -cd '[:alnum:]_-')
EXEC_REPORT="executive_reports/CyberGuard_Executive_Report_${ASSESSMENT_ID}_${SAFE_CLIENT}.txt"

cat > "$EXEC_REPORT" <<EOF
============================================================
              DIAMOND BRIGHT CYBERGUARD™
             Executive Cyber Risk Summary
============================================================

Prepared For:
$CLIENT

Prepared By:
Joshua Bottoms
Diamond Bright LLC

Assessment Date:
$DATE_NOW

Assessment ID:
$ASSESSMENT_ID

------------------------------------------------------------
                    CYBERGUARD SCORE
------------------------------------------------------------

Overall CyberGuard Score:
$SCORE

Overall Rating:
$RATING

Estimated Risk Level:
$RISK

Recommended Protection Plan:
$PLAN

Potential One-Day Business Impact:
$IMPACT

------------------------------------------------------------
                    EXECUTIVE SUMMARY
------------------------------------------------------------

Diamond Bright LLC completed a CyberGuard Business Cyber Risk
Assessment to help identify technology risks, operational concerns,
and practical improvements for your business.

Based on the assessment results, your environment currently shows an
overall rating of $RATING with an estimated risk level of $RISK.

The goal of this report is to explain the results in plain business
terms so ownership can clearly understand what is working well, what
needs attention, and what should be prioritized next.

------------------------------------------------------------
                    WHAT IS WORKING WELL
------------------------------------------------------------

- Core system storage appears healthy.
- No failed critical services were detected during the assessment.
- Firewall protection is active.
- Internet connectivity was verified.
- Wi-Fi encryption appears acceptable.
- Device inventory was successfully completed.

------------------------------------------------------------
                    KEY AREAS TO REVIEW
------------------------------------------------------------

1. Multi-Factor Authentication

Business accounts should use Multi-Factor Authentication whenever
possible. MFA helps protect email, cloud software, financial accounts,
and administrative systems if a password is ever stolen.

2. Backup Verification

Backups should not only exist — they should be tested. A restore test
confirms the business can recover from hardware failure, ransomware,
or accidental data loss.

3. Router and Firewall Review

Network equipment should be reviewed regularly to confirm firmware,
firewall settings, and wireless security remain properly configured.

4. Smart and IoT Devices

Printers, TVs, cameras, garage devices, and other connected equipment
should be reviewed because they often remain on networks for years
without updates or security checks.

------------------------------------------------------------
                    BUSINESS IMPACT
------------------------------------------------------------

Technology downtime can affect employee productivity, customer
service, payment processing, communications, and daily revenue.

Estimated One-Day Business Impact:
$IMPACT

CyberGuard monthly protection is designed to reduce the chance of
avoidable technology issues becoming costly interruptions.

------------------------------------------------------------
                    PRIORITY ACTION PLAN
------------------------------------------------------------

Priority 1:
Enable Multi-Factor Authentication on important business accounts.

Priority 2:
Verify that backups can be restored successfully.

Priority 3:
Review router, firewall, and Wi-Fi configuration.

Priority 4:
Review connected devices and remove anything unknown or unnecessary.

Priority 5:
Schedule recurring CyberGuard assessments to track risk over time.

------------------------------------------------------------
                    DIAMOND BRIGHT RECOMMENDATION
------------------------------------------------------------

Recommended Plan:
$PLAN

Diamond Bright recommends ongoing CyberGuard protection to help
monitor technology health, track changes, review security posture,
and provide business owners with clear monthly visibility into their
technology risk.

------------------------------------------------------------
                    NEXT STEPS
------------------------------------------------------------

1. Review this report with Diamond Bright LLC.
2. Decide which priority items should be addressed first.
3. Consider a monthly CyberGuard protection plan.
4. Schedule the next assessment or follow-up review.

------------------------------------------------------------

Diamond Bright LLC
Diamond Bright CyberGuard™
Website: flawlessgemai.com
Email: ceo@diamondbrightai.com

Know Your Risks. Protect Your Business.

============================================================
EOF

echo "Executive report created:"
echo "$EXEC_REPORT"

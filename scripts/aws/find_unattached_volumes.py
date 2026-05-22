import boto3

PROFILE = "devops-admin"
REGION = "us-east-2"

session = boto3.Session(profile_name=PROFILE, region_name=REGION)
ec2 = session.client("ec2")

response = ec2.describe_volumes(
    Filters=[
        {"Name": "status", "Values": ["available"]}
    ]
)

volumes = response["Volumes"]

print(f"Unattached EBS Volumes - {REGION}")
print("-" * 80)

if not volumes:
    print("No unattached volumes found.")
else:
    for volume in volumes:
        print(
            f"{volume['VolumeId']} | "
            f"{volume['Size']} GiB | "
            f"{volume['VolumeType']} | "
            f"{volume['AvailabilityZone']} | "
            f"{volume['CreateTime']}"
        )

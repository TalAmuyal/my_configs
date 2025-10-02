# /// script
# requires-python = ">=3.11"
# dependencies = [
#   "typer",
#   "boto3",
# ]
# ///

import boto3
import typer


def main(private_ip: str) -> None:
    ec2_client = boto3.client("ec2")
    instance = find_instance_by_private_ip(ec2_client, private_ip)
    if instance is None:
        print("No instances found")
        exit(-1)

    instance_name = get_instance_name(instance)
    if typer.confirm(f"Are you sure you want to terminate {instance_name}?"):
        ec2_client.terminate_instances(InstanceIds=[instance["InstanceId"]])
        print("Terminating...")
        wait_for_termination()
        print("Terminated")
    else:
        print("Aborted")


def find_instance_by_private_ip(ec2_client, private_ip: str):
    response = ec2_client.describe_instances(
        Filters=[
            {
                'Name': 'private-ip-address',
                'Values': [private_ip]
            }
        ]
    )

    instances = response['Reservations'][0]['Instances']
    if len(instances) > 1:
        raise Exception("Multiple instances found")
    if len(instances) == 1:
        return instances[0]
    return None


def get_instance_name(instance) -> str:
    for tag in instance["Tags"]:
        if tag["Key"] == "Name":
            return tag["Value"]

    raise Exception(f"Name not found ({instance.tags})")


def wait_for_termination(
    ec2_client,
    private_ip: str,
) -> None:
    waiter = ec2_client.get_waiter("instance_terminated")
    waiter.wait(
        Filters=[
            {
                "Name": "private-ip-address",
                "Values": [private_ip],
            },
        ],
    )


if __name__ == "__main__":
    typer.run(main)

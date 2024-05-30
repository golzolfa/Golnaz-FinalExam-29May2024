#!/usr/bin/env node
import 'source-map-support/register';
import * as cdk from 'aws-cdk-lib';
import { GolnazResourcesStack } from '../lib/cdk-golnaz-resources-stack';

const app = new cdk.App();
new GolnazResourcesStack(app, 'GolnazResourcesStack');
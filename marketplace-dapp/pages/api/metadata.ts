import type { NextApiRequest, NextApiResponse } from "next";
import { METADATA } from "../../data/metadata";

type Data = {
  name: string;
};

export default function handler(
  req: NextApiRequest,
  res: NextApiResponse<Data>
) {
  res.status(200).json(METADATA);
}

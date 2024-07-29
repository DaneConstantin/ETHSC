"use client";

import type { NextPage } from "next";
import { useRouter } from "next/navigation";
const Home: NextPage = () => {
  const router = useRouter()
  return (
    <>
      <div className="flex items-center flex-col flex-grow pt-10">
        <h1 className="text-4xl font-extrabold text-gray-900 dark:text-white mb-6">Welcome to Solid Luxury</h1>
        <button onClick={() => router.push("/debug")} className="btn btn-secondary btn-lg px-12 font-light hover:border-transparent bg-base-100 hover:bg-secondary my-auto">Start Here</button>
      </div >
    </>
  );
};

export default Home;

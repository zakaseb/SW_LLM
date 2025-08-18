# Running Open SWE with Ollama

This guide provides instructions on how to set up and run the Open SWE project with a local Ollama instance, instead of using cloud-based LLM providers.

## Prerequisites

Before you begin, ensure you have the following installed:

- **Node.js (version 18 or higher)**
- **Yarn (version 3.5.1 or higher)**
- **Git**
- **Ollama**: Follow the instructions on the [Ollama website](https://ollama.com/) to download and install it on your system.

## Setup Instructions

### 1. Clone the Repository

First, clone the Open SWE repository to your local machine:

```bash
git clone https://github.com/langchain-ai/open-swe.git
cd open-swe
```

### 2. Install Dependencies

Install all the required dependencies using Yarn from the repository root:

```bash
yarn install
```

This command will install the dependencies for all packages in the monorepo, including the newly added `@langchain/ollama` package.

### 3. Set Up Ollama

Once Ollama is installed, you need to pull a model. We recommend using `llama3`, but you can choose any other model from the Ollama library.

```bash
ollama pull llama3
```

After pulling the model, make sure the Ollama server is running. You can check the status of the server by running:

```bash
ollama ps
```

By default, the Ollama server runs on `http://localhost:11434`.

### 4. Configure Environment Variables

The project uses environment variables to manage configuration. You'll need to create and configure `.env` files for both the web app and the agent.

#### Web App Environment File

Copy the example environment file for the web app:

```bash
cp apps/web/.env.example apps/web/.env
```

You will need to set up a GitHub App and fill in the corresponding variables in this file. Follow the instructions in the main `README.md` file for creating a GitHub App.

#### Agent Environment File

Copy the example environment file for the agent:

```bash
cp apps/open-swe/.env.example apps/open-swe/.env
```

Open the `apps/open-swe/.env` file and configure the following variables:

- **`OLLAMA_BASE_URL`**: The URL of your local Ollama server. If you are running it locally with the default port, the value should be `http://localhost:11434`.
- **`OLLAMA_MODEL`**: The name of the Ollama model you want to use (e.g., `llama3`).
- **GitHub App Secrets**: Fill in the `GITHUB_APP_NAME`, `GITHUB_APP_ID`, `GITHUB_APP_PRIVATE_KEY`, and `GITHUB_WEBHOOK_SECRET` variables with the values from your GitHub App.

You can leave the `ANTHROPIC_API_KEY`, `OPENAI_API_KEY`, and `GOOGLE_API_KEY` variables empty.

### 5. Start the Development Servers

With the environment variables configured, you can now start the development servers. You'll need to run the web app and the agent in separate terminal windows.

**Terminal 1: Start the Agent**

```bash
# In the root of the project
cd apps/open-swe
yarn dev
```

This will start the LangGraph agent server at `http://localhost:2024`.

**Terminal 2: Start the Web App**

```bash
# In the root of the project
cd apps/web
yarn dev
```

This will start the Next.js web app at `http://localhost:3000`.

### 6. Verification

Once both servers are running, you can access the web app by navigating to `http://localhost:3000` in your browser. You should be able to log in with your GitHub account and start using the Open SWE agent, which will now be powered by your local Ollama instance.

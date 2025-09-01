export class SandboxClient {
  constructor(..._: any[]) {}
  async run(..._: any[]) {
    throw new Error("Daytona sandbox is disabled in local mode");
  }
}

export const connect = (..._: any[]) => {
  return new Daytona();
};

export class Daytona {
    create(..._: any[]) {
        return new Sandbox();
    }
    get(..._: any[]) {
        return new Sandbox();
    }
    stop(..._: any[]) {}
    delete(..._: any[]) {}
}
export class Sandbox {
    id = "local";
    state = "running";
    process = {
        start: (..._: any[]) => {},
        stop: (..._: any[]) => {},
        executeCommand: (..._: any[]) => Promise.resolve({ exitCode: 0, stdout: "", stderr: "", result: "" as any }),
    };
    git = {
        clone: (..._: any[]) => {},
        commit: (..._: any[]) => {},
        push: (..._: any[]) => {},
        checkout: (..._: any[]) => {},
        diff: (..._: any[]) => {},
        add: (..._: any[]) => {},
        pull: (..._: any[]) => {},
        status: (..._: any[]) => {},
        createBranch: (..._: any[]) => {},
    }
    delete(..._: any[]) {}
    start(..._: any[]) {}
}
export const enum SandboxState {
    RUNNING = "RUNNING",
    STOPPED = "STOPPED",
    ARCHIVED = "ARCHIVED",
}
export type CreateSandboxFromSnapshotParams = any;

type NewToken = {
    Name?: string,
    KeyId: string,
    ApiKey: string,
    GroupId: number | string,
    UseCache?: boolean,
}

type XpReturn = {
    Code: "Success" | "NotSetup" | "Failed",
    OldAmount: number,
    NewAmount: number,
}

type RankReturn = {
    id: number,
    locked: boolean,
    name: string,
    perm: number,
    rank: number,
    xp: number,
    prefix: string,
    prefixEnabled: boolean,
    role: string,
    roleEnabled: boolean,
}

type RoleReturn = {
    id: number,
    name: string,
    rank: number,
    memberCount: number,
    ID: number,
}
type MedalReturn = {
    Description: string,
    Name: string,
    Emoji: string,
    Id: number,
}
type UserMedalReturn = {
    amount: number,
    id: string | number,
}

interface UtilServerReturn {
    CreateToken: (TokenData: NewToken) => APIpoints,
    GetToken: (TokenName: string) => APIpoints,
    DeleteToken: (TokenName: string) => boolean,
    QuickClean: () => boolean,
}


type APIpoints = {
    XP: {
        GetXp: (userId: number | string) => number,
        IncrementXp: (userId: number | string, amount: number | string) => XpReturn,
        SetXp: (userId: number | string, amount: number | string) => XpReturn,
    },
    RANK: {
        GetUserRank: (
            userId: number | string
        ) => { Previous: RankReturn | undefined, Current: RankReturn | undefined, Next: RankReturn | undefined },
        GetAllRanks: () => RankReturn[],
        PromoteUser: (userId: number | string) => { newRole: RoleReturn | undefined, oldRole: RoleReturn | undefined },
        DemoteUser: (userId: number | string) => { newRole: RoleReturn | undefined, oldRole: RoleReturn | undefined },
        SetUserRank: (
            userId: number | string,
            rank: number | string
        ) => { newRole: RoleReturn | undefined, oldRole: RoleReturn | undefined },
    },
    MEDALS: {
        GetAllMedals: () => MedalReturn[],
        GetUserMedals: (userId: number | string) => MedalReturn[] & UserMedalReturn[]
        GetUserMedalCount: (userId: number | string, medalId: number | string) => UserMedalReturn[] | "nomedal",
        AddUserMedal: (userId: number | string, medalId: number | string) => "added1" | "createdStore",
        RemoveUserMedal: (
            userId: number | string,
            medalId: number | string
        ) => "removed1" | "deletedStore" | "doesntHaveMedal"
    },
    PENDING: {
        AcceptUser: (userId: number | string) => boolean,
        DeclineUser: (userId: number | string) => boolean,
    },
}

declare const ClannyAPI: UtilServerReturn;

export = ClannyAPI;

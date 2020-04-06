// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

#pragma once

#include "../../common/DMInterfaces.h"

namespace Microsoft { namespace Azure { namespace DeviceManagement { namespace Client {

    class MdmServer : public DMCommon::IMdmServer
    {
        MdmServer();
    public:
        static std::shared_ptr<DMCommon::IMdmServer> GetInstance();

        std::string RunSyncML(const std::string& sid, const std::string& syncML);
    private:
        friend std::_Ref_count_obj2<MdmServer>;
        friend void std::_Construct_in_place<MdmServer>(MdmServer&);

        static std::shared_ptr<MdmServer> _this;
        static std::recursive_mutex _lock;
    };

}}}}
